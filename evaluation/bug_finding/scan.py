#!/usr/bin/python3

import argparse
import subprocess
import sys
import signal
import time
import os
import shutil
import psutil
import requests
import json
import stat
from distutils.dir_util import copy_tree

# Constants
PWD = os.getcwd()
PATH_EXAKAT = PWD + "/image_exakat/"
PATH_PHPCS = PWD + "/image_phpcs/"
PATH_PROGPILOT = PWD + "/image_progpilot/"
PATH_RIPS = PWD + "/image_rips/"
PATH_SONARSOURCE = PWD  + "/image_sonarsource/"
PATH_RIPS_JSON = PATH_RIPS + "rips-v055-modified/scan_result.json"
PATH_EXAKAT_DB = PATH_EXAKAT + "scan_result/dump.sqlite"
PATH_PHPCS_JSON = PATH_PHPCS + "scan_result.json"
PATH_PROGPILOT_JSON = PATH_PROGPILOT + "scan_result.json"
PATH_SONARSOURCE_JSON = PATH_SONARSOURCE + "scan_result.json"
PATH_DVWA = PWD + "/dvwa-master"
CONTAINER_NAME_EXAKAT = "phpScanExakat"
CONTAINER_NAME_PHPCS = "phpScanPhpcs"
CONTAINER_NAME_PROGPILOT = "phpScanProgpilot"
CONTAINER_NAME_RIPS = "phpScanRips"
CONTAINER_NAME_SONARQUBE = "phpScanSonarqubeServer"
IMG_NAME_EXAKAT = "img_exakat"
IMG_NAME_PHPCS = "img_phpcs"
IMG_NAME_PROGPILOT = "img_progpilot"
IMG_NAME_RIPS = "img_rips"
IMG_NAME_SONARQUBE_SERVER = "sonarqube:latest"
IMG_NAME_SONAR_SCANNER = "sonarsource/sonar-scanner-cli"
URL_CHANGE_DEFAULT_PW = "http://localhost:9000/api/users/change_password"
URL_SONARQUBE_UP = "http://localhost:9000/api"
URL_SCAN_RESULT = "http://localhost:9000/api/hotspots/search?projectKey=scan_result&p=1&ps=500&status=TO_REVIEW&onlyMine=false&sinceLeakPeriod=false"
URL_DVWA_GIT = "https://github.com/digininja/DVWA.git"


# Globals
path_current = None
container_name_current = None
scanner_process = None
sonarqube_process = None

# Class containting special strings for coloring bash output
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


# Kills process and all its childs recursively
def kill(proc_pid):
    process = psutil.Process(proc_pid)
    for proc in process.children(recursive=True):
        proc.kill()
    process.kill()

   
# Stops and removes docker container with specified name
def removeContainer(container_name):
   cmd_container_id = "docker ps -f 'name=" + container_name + "' -a -q"

   proc_container_id = subprocess.Popen(cmd_container_id, stdout=subprocess.PIPE, shell=True)
   proc_container_id.wait()

   container_id = proc_container_id.stdout.read().decode("utf-8").rstrip()
   if (container_id == ""):
      return

   print(colorCyan("Grabbed container ID: " + container_id))
   print(colorCyan("Stopping and removing old container..."))

   cmd_stop_container = "docker stop " + container_id
   subprocess.Popen(cmd_stop_container, stdout=subprocess.PIPE, shell=True).wait()

   cmd_rm_container = "docker rm " + container_id
   subprocess.Popen(cmd_rm_container, stdout=subprocess.PIPE, shell=True).wait()

   print(colorCyan("Done.\n"))


# Color string in green for bash output
def colorGreen(input_str) -> str:
   return bcolors.OKGREEN + input_str + bcolors.ENDC


# Color string to cyan for bash output
def colorCyan(input_str) -> str:
   return bcolors.OKCYAN + input_str + bcolors.ENDC


# Print string in red color
def printError(input_str):
   print(bcolors.FAIL + input_str + bcolors.ENDC)


# Print string in warning color
def printWarning(input_str):
   print(bcolors.WARNING + input_str + bcolors.ENDC)


# Removes any characters of bcolors class from string
def removeColors(input_str) -> str:
   ret_str = input_str.replace(bcolors.HEADER,"")
   ret_str = ret_str.replace(bcolors.OKBLUE,"")
   ret_str = ret_str.replace(bcolors.OKCYAN,"")
   ret_str = ret_str.replace(bcolors.OKGREEN,"")
   ret_str = ret_str.replace(bcolors.WARNING,"")
   ret_str = ret_str.replace(bcolors.FAIL,"")
   ret_str = ret_str.replace(bcolors.ENDC,"")
   ret_str = ret_str.replace(bcolors.BOLD,"")
   ret_str = ret_str.replace(bcolors.UNDERLINE,"")
   return ret_str


# Callback function for CTRL+C event
# In order to gracefully stop docker containers executed through this python script
def signalHandler(signal_inner, frame):
   global scanner_process
   global container_name_current
   global path_current
   global sonarqube_process

   # Terminate process which executes the current scanner
   if scanner_process:
      kill(scanner_process.pid)

   # Terminate sonarqube server if it is up
   if sonarqube_process != None:
      kill(sonarqube_process.pid)
   
   printWarning("\nCtrl+C received. Trying to shut down running docker containers")

   # Stop sonarqube server docker if it is up
   if sonarqube_process != None:
      cmd_container_id = "docker ps -f 'name=" + CONTAINER_NAME_SONARQUBE + "' -f 'status=running' -a -q"

      proc_container_id = subprocess.Popen(cmd_container_id, stdout=subprocess.PIPE, shell=True)
      proc_container_id.wait()

      container_id = proc_container_id.stdout.read().decode("utf-8").rstrip()
      if (container_id == ""):
         sys.exit(0)
   
      printWarning("Grabbed container ID (Sonarqube server): " + container_id)

      cmd_docker_stop = "docker stop " + container_id
      printWarning("Stopping docker container. Please wait a few seconds...")
      subprocess.Popen(cmd_docker_stop, stdout=subprocess.PIPE, shell=True).wait()

   if container_name_current != None:
      # Build command to grab container ID of running container
      cmd_container_id = "docker ps -f 'name=" + container_name_current + "' -f 'status=running' -a -q"

      proc_container_id = subprocess.Popen(cmd_container_id, stdout=subprocess.PIPE, shell=True)
      proc_container_id.wait()

      container_id = proc_container_id.stdout.read().decode("utf-8").rstrip()
      if (container_id == ""):
         sys.exit(0)
      
      printWarning("Grabbed container ID: " + container_id)
      
      # Build command to stop docker container
      cmd_docker_stop = "docker stop " + container_id
      printWarning("Stopping docker container. Please wait a few seconds...")
      subprocess.Popen(cmd_docker_stop, stdout=subprocess.PIPE, shell=True).wait()

   sys.exit(0)


# Deletes specified folder and all its content
def removeFolder(path_folder):
   try:
      shutil.rmtree(path_folder)
   except OSError as e:
      print("Error: %s - %s." % (e.filename, e.strerror))


# Deletes specified folder's content
def removeFolderContents(path_folder):
   for filename in os.listdir(path_folder):
      file_path = os.path.join(path_folder, filename)
      try:
         if os.path.isfile(file_path) or os.path.islink(file_path):
            os.unlink(file_path)
         elif os.path.isdir(file_path):
            shutil.rmtree(file_path)
      except Exception as e:
         print('Failed to delete %s. Reason: %s' % (file_path, e))
         sys.exit(1)


# First cleans up destination directory, then copies files into it
def copyCode(path_from, path_to):
   print(colorCyan("\n--------- Copying code to local directory ---------\n"))
   removeFolderContents(path_to)
   if os.path.isdir(path_from):
      # Directory
      copy_tree(path_from, path_to)
   else:
      # Single file
      shutil.copy(path_from, path_to)


def imageExists(img_name):
   # cmd_img_exists = "docker images " + img_name + " -a -q"

   # proc_image_exists = subprocess.Popen(cmd_img_exists, stdout=subprocess.PIPE, shell=True)
   # proc_image_exists.wait()

   # img_hash = proc_image_exists.stdout.read().decode("utf-8").rstrip()
   # if (img_hash == ""):
   #    return False
   # else:
   #    return True
   return False


def buildImage(path_dockerfile, img_name):
   print(colorCyan("Building Docker image " + img_name))

   cmd_build_img = "docker build " + path_dockerfile + " -t " + img_name

   proc_build_img = subprocess.Popen(cmd_build_img, stdout=sys.stdout, shell=True)
   proc_build_img.wait()


def callParser(scanner):
   # Call parse.py to parse and output scan results
   cmd_parse_results = "python3 parse.py -s " + scanner
   subprocess.Popen(cmd_parse_results, stdout=sys.stdout, shell=True).wait()


def cloneDVWA():
   removeFolder(PATH_DVWA)
   cmd_clone_dvwa = "git clone --depth 1 " + URL_DVWA_GIT + " " + PATH_DVWA
   print(colorCyan("--------- Cloning DVWA ---------\n"))

   clone_process = subprocess.Popen(cmd_clone_dvwa, stdout=sys.stdout, shell=True)
   clone_process.wait()


def scanExakat(path_input):
   global scanner_process

   # Since some scanners have side effects, we copy the code of the given
   # path into a locally defined directory
   copyCode(path_input, PATH_EXAKAT + "/code")

   if not imageExists(IMG_NAME_EXAKAT):
      buildImage(PATH_EXAKAT, IMG_NAME_EXAKAT)

   # Build command to execute scanner
   cmd_execute_scanner = "docker run -v " + PATH_EXAKAT + ":/usr/src/exakat/projects --name " + CONTAINER_NAME_EXAKAT + " -t " + IMG_NAME_EXAKAT + " /bin/bash -c "
   cmd_execute_scanner += "\"echo '" + colorCyan("--------- Initializing git ---------") + "';"
   cmd_execute_scanner += "cd /usr/src/exakat/projects/code;"
   cmd_execute_scanner += "git config --global user.email 'max@mustermann.com';"
   cmd_execute_scanner += "git config --global user.name 'Max Mustermann';"
   cmd_execute_scanner += "rm -rf .git;"
   cmd_execute_scanner += "git init;"
   cmd_execute_scanner += "git add .;"
   cmd_execute_scanner += "git commit -m 'foo';"
   cmd_execute_scanner += "rm /usr/src/exakat/projects/scan_result -rf;"
   cmd_execute_scanner += "echo '" + colorCyan("--------- Initializing project ---------") + "';"
   cmd_execute_scanner += "exakat init -p scan_result -R /usr/src/exakat/projects/code;"
   cmd_execute_scanner += "echo '" + colorCyan("--------- Scanning project ---------") + "';"
   cmd_execute_scanner += "exakat project -v -p scan_result;"
   cmd_execute_scanner += "rm -rf .git;"
   cmd_execute_scanner += "echo '" + colorCyan("Done. Results saved in /scan_result") + "'\""

   # Remove existing container with same name (from previous scans)
   removeContainer(CONTAINER_NAME_EXAKAT)

   print(colorGreen(removeColors(cmd_execute_scanner)))
   # Start scanner as blocking process, output to sys.stdout
   scanner_process = subprocess.Popen(cmd_execute_scanner, stdout=sys.stdout, shell=True)
   scanner_process.wait()

   # Read scan results from sqlite db file
   if not os.path.exists(PATH_EXAKAT_DB):
      printError("ERROR: Sqlite file not found in " + PATH_EXAKAT_DB)
      sys.exit(1)

   callParser("exakat")


def stopSonarqube():
   cmd_stop_sonarqube = "docker stop $(docker ps --filter ancestor=sonarqube -q)"
   stop_process = subprocess.Popen(cmd_stop_sonarqube, stdout=subprocess.PIPE, shell=True).wait()


def scanPhpcs(path_input):
   global scanner_process

   # Since some scanners have side effects, we copy the code of the given
   # path into a locally defined directory
   copyCode(path_input, PATH_PHPCS + "/code")

   if not imageExists(IMG_NAME_PHPCS):
      buildImage(PATH_PHPCS, IMG_NAME_PHPCS)

   # Build command to execute scanner
   cmd_execute_scanner = "docker run -v " + PATH_PHPCS + ":/tmp/foo --name " + CONTAINER_NAME_PHPCS + " -t " + IMG_NAME_PHPCS + " /bin/bash -c "
   cmd_execute_scanner += "\"echo '" + colorCyan("--------- Starting scan ---------") + "';"
   cmd_execute_scanner += "/tmp/vendor/bin/phpcs --report=json --extensions=php,inc,lib,module,info --standard=/tmp/vendor/pheromone/phpcs-security-audit/example_base_ruleset.xml /tmp/foo/code > /tmp/foo/scan_result.json || true;"
   cmd_execute_scanner += "echo '" + colorCyan("--------- Scan result saved in scan_result.json ---------") + "';\""

   # Remove existing container with same name (from previous scans)
   removeContainer(CONTAINER_NAME_PHPCS)

   print(colorGreen(removeColors(cmd_execute_scanner)))
   # Start scanner as blocking process, output to sys.stdout
   scanner_process = subprocess.Popen(cmd_execute_scanner, stdout=sys.stdout, shell=True)
   scanner_process.wait()

   # Read scan results from json file
   if not os.path.exists(PATH_PHPCS_JSON):
      printError("ERROR: JSON file not found in " + PATH_PHPCS_JSON)
      sys.exit(1)
   
   callParser("phpcs")


def scanProgpilot(path_input):
   global scanner_process

   # Since some scanners have side effects, we copy the code of the given
   # path into a locally defined directory
   copyCode(path_input, PATH_PROGPILOT + "/code")

   if not imageExists(IMG_NAME_PROGPILOT):
      buildImage(PATH_PROGPILOT, IMG_NAME_PROGPILOT)

   # Build command to execute scanner
   cmd_execute_scanner = "docker run -v " + PATH_PROGPILOT + ":/home/ --name " + CONTAINER_NAME_PROGPILOT + " -t " + IMG_NAME_PROGPILOT + " /bin/bash -c "
   cmd_execute_scanner += "\"rm -f /home/scan_result.json;"
   cmd_execute_scanner += "chmod +x /home/progpilot_v0.8.0.phar;"
   cmd_execute_scanner += "cp /home/progpilot_v0.8.0.phar /usr/local/bin/progpilot;"
   cmd_execute_scanner += "echo '" + colorCyan("--------- Scanning code ---------") + "';"
   cmd_execute_scanner += "progpilot /home/code/ > /home/scan_result.json || true;"
   cmd_execute_scanner += "echo '" + colorCyan("Scan result saved in scan_result.json") + "'\""

   # Remove existing container with same name (from previous scans)
   removeContainer(CONTAINER_NAME_PROGPILOT)

   print(colorGreen(removeColors(cmd_execute_scanner)))
   # Start scanner as blocking process, output to sys.stdout
   scanner_process = subprocess.Popen(cmd_execute_scanner, stdout=sys.stdout, shell=True)
   scanner_process.wait()

   # Read scan results from json file
   if not os.path.exists(PATH_PROGPILOT_JSON):
      printError("ERROR: JSON file not found in " + PATH_PROGPILOT_JSON)
      sys.exit(1)

   callParser("progpilot")


def scanRips(path_input):
   global scanner_process

   # Since some scanners have side effects, we copy the code of the given
   # path into a locally defined directory
   copyCode(path_input, PATH_RIPS + "/code")

   if not imageExists(IMG_NAME_RIPS):
      buildImage(PATH_RIPS, IMG_NAME_RIPS)

   # Build command to execute scanner
   cmd_execute_scanner = "docker run -v " + PATH_RIPS + ":/home/ --name " + CONTAINER_NAME_RIPS + " -t " + IMG_NAME_RIPS + " /bin/bash -c "
   cmd_execute_scanner += "\"echo '" + colorCyan("--------- Starting web server ---------") + "';"
   cmd_execute_scanner += "cd /home/rips-v055-modified/;"
   cmd_execute_scanner += "php7.4 -S localhost:9000 & sleep 3;"
   cmd_execute_scanner += "echo '" + colorCyan("--------- Executing scan with cURL ---------") + "';"
   cmd_execute_scanner += "curl http://localhost:9000/main.php --data-raw 'loc=%2Fhome%2Fcode&subdirs=1&verbosity=1&vector=all&treestyle=1&stylesheet=ayti&ignore_warning=1' > /home/scan_result.html;"
   cmd_execute_scanner += "echo '" + colorCyan("Done. result saved in scan_result.json") + "'\""

   # Remove existing container with same name (from previous scans)
   removeContainer(CONTAINER_NAME_RIPS)

   print(colorGreen(removeColors(cmd_execute_scanner)))

   # Start scanner as blocking process, output to sys.stdout
   scanner_process = subprocess.Popen(cmd_execute_scanner, stdout=sys.stdout, shell=True)
   scanner_process.wait()

   # Read scan results from html file
   if not os.path.exists(PATH_RIPS_JSON):
      printError("ERROR: JSON file not found in " + PATH_RIPS_JSON)
      sys.exit(1)

   callParser("rips")


def scanSonarsource(path_input):
   global scanner_process
   global sonarqube_process

   # Since some scanners have side effects, we copy the code of the given
   # path into a locally defined directory
   copyCode(path_input, PATH_SONARSOURCE + "/code")

   # Command to start Sonarqube servers
   cmd_start_server = "docker run -p 9000:9000 --name " + CONTAINER_NAME_SONARQUBE + " " + IMG_NAME_SONARQUBE_SERVER

   # Remove existing container with same name (from previous scans)
   removeContainer(CONTAINER_NAME_SONARQUBE)

   # Start server (non-blocking)
   sonarqube_process = subprocess.Popen(cmd_start_server, stdout=subprocess.PIPE, shell=True)

   print("Waiting for SonarQube server to be up on localhost:9000... (This takes a moment)")

   # Wait until server is up
   while True:
      try:
         req = requests.get(URL_SONARQUBE_UP)
         if req.status_code == 401:
            print("SonarQube Server up")
            break
      except:
         continue
      time.sleep(1)

   time.sleep(2)

   # Change default password because SonarQube server requires us to
   params = (
      ('login', 'admin'),
      ('previousPassword', 'admin'),
      ('password', 'admin1'),
   )

   # Use API to change password through a request
   pw_change = requests.post(URL_CHANGE_DEFAULT_PW, params=params, auth=('admin', 'admin'))
   if pw_change.status_code != 204:
      printError(f"ERROR: Default password change failed with status code {pw_change.status_code}")
      exit(1)

   # Build command to execute sonar-scanner-cli
   cmd_execute_scanner = 'docker run --rm -e SONAR_HOST_URL="http://localhost:9000" -v ' + PATH_SONARSOURCE + 'code:/usr/src --network=host ' + IMG_NAME_SONAR_SCANNER + ' -D sonar.projectKey=scan_result -D sonar.forceAuthentication=false -D sonar.login=admin -D sonar.password=admin1'

   print(colorGreen(removeColors(cmd_execute_scanner)))

   # Start scanner as blocking process, output to sys.stdout
   scanner_process = subprocess.Popen(cmd_execute_scanner, stdout=sys.stdout, shell=True)
   scanner_process.wait()

   # Export scan result as JSON through provided web API
   # Results may need some time to be able to fetch through web API
   seconds = 0
   while seconds < 20:
      result = requests.get(URL_SCAN_RESULT, auth=('admin', 'admin1'))
      parsedJSON = json.loads(result.text)
      if len(parsedJSON["hotspots"]) != 0:
         break
      time.sleep(2.0)
      seconds += 2
   
   if len(parsedJSON["hotspots"]) == 0:
      printError(f"ERROR: Couldn't fetch scan results through Web API.\n\nGot: {parsedJSON}")
      sys.exit(1)

   # Stop sonarqube server
   print("Stopping SonarQube Server...")
   stopSonarqube()
   kill(sonarqube_process.pid)

   with open(PATH_SONARSOURCE_JSON, "w") as f:
      f.write(result.text)

   callParser("sonarsource")



if __name__ == "__main__":
   parser = argparse.ArgumentParser()
   parser.add_argument("-s", "--scanner", help="Define one or more scanner(s) to be used (exakat, phpcs, progpilot, rips, sonarsource, all). Choosing 'all' will execute all scanners", nargs='+', required=True)
   parser.add_argument("-i", "--input", help="Define path which contains code to be scanned", required=True)
   args = parser.parse_args()

   # Register callback function for CTRL+C event
   signal.signal(signal.SIGINT, signalHandler)


   if args.input == "dvwa":
      cloneDVWA()
      args.input = PATH_DVWA
   elif not os.path.exists(args.input):
      printError("ERROR: Bad input path given: " + args.input)
      sys.exit(1)

   if args.scanner[0] == "all":
      selectedScanners = ["exakat", "phpcs", "progpilot", "rips", "sonarsource"]
   else:
      selectedScanners = args.scanner

   for scanner in selectedScanners:
      if scanner == "exakat":
         path_current = PATH_EXAKAT
         container_name_current = CONTAINER_NAME_EXAKAT
         scanExakat(args.input)
      elif scanner == "phpcs":
         path_current = PATH_PHPCS
         container_name_current = CONTAINER_NAME_PHPCS
         scanPhpcs(args.input)
      elif scanner == "progpilot":
         path_current = PATH_PROGPILOT
         container_name_current = CONTAINER_NAME_PROGPILOT
         scanProgpilot(args.input)
      elif scanner == "rips":
         path_current = PATH_RIPS
         container_name_current = CONTAINER_NAME_RIPS
         scanRips(args.input)
      elif scanner == "sonarsource":
         path_current = PATH_SONARSOURCE
         container_name_current = None
         scanSonarsource(args.input)
      else:
         printError("ERROR: Unknown scanner specified. Use -h for help")
         sys.exit(1)