#!/usr/bin/python3

import argparse
import sqlite3
import sys
import os
import json
from enum import Enum

# Constants
PWD = os.getcwd()
PATH_EXAKAT = PWD + "/image_exakat/"
PATH_PHPCS = PWD + "/image_phpcs/"
PATH_PROGPILOT = PWD + "/image_progpilot/"
PATH_RIPS = PWD + "/image_rips/"
PATH_SONARSOURCE = PWD + "/image_sonarsource/"
PATH_SCAN_RESULT_EXAKAT = PATH_EXAKAT + "scan_result/dump.sqlite"
PATH_SCAN_RESULT_PHPCS = PATH_PHPCS + "scan_result.json"
PATH_SCAN_RESULT_PROGPILOT = PATH_PROGPILOT + "scan_result.json"
PATH_SCAN_RESULT_RIPS = PATH_RIPS + "rips-v055-modified/scan_result.json"
PATH_SCAN_RESULT_SONARSOURCE = PATH_SONARSOURCE + "scan_result.json"
PATH_EXPORT_RESULT = PWD + "/export_result.json"

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


class VulnType(Enum):
    XSS = 1
    SQLI = 2
    CSRF = 3
    RCE = 4
    XXE = 5
    OTHER = 6


class Vulnerability:
    def __init__(self, filepath: str, line: int, vulnType: VulnType):
        self.filepath = filepath
        self.line = line
        self.vulnType = vulnType
        # TODO: severity?

    def __str__(self) -> str:
        return self.filepath + "," + str(self.line) + "," + str(self.vulnType)


# Print string in red color
def printError(input_str):
    print(bcolors.FAIL + input_str + bcolors.ENDC)


# Print string in warning color
def printWarning(input_str):
   print(bcolors.WARNING + input_str + bcolors.ENDC)


def getFilePaths(argsInput, argsScanner) -> dict:
    filePathDict = {}
    if argsInput:
        # -- Don't use default paths --
        # Check if len(args.scanner) == len(args.input)
        if len(argsScanner) != len(argsInput):
            printError(
                f"ERROR: Length of -s option ({len(argsScanner)}) does not match length of -i option ({len(argsInput)}). If default paths should be used, don't use -i")
            sys.exit(1)

        # Collect file paths given through command line
        for i in range(len(argsInput)):
            curr = argsInput[i]
            if argsScanner[i] == "exakat":
                filePathDict["exakat"] = curr
            elif argsScanner[i] == "phpcs":
                filePathDict["phpcs"] = curr
            elif argsScanner[i] == "progpilot":
                filePathDict["progpilot"] = curr
            elif argsScanner[i] == "rips":
                filePathDict["rips"] = curr
            elif argsScanner[i] == "sonarsource":
                filePathDict["sonarsource"] = curr
            else:
                printError(
                    f"ERROR: Unrecognized scanner specified: {argsScanner[i]}")
                sys.exit(1)
    else:
        # -- Use default paths --
        for scanner in argsScanner:
            if scanner == "exakat":
                filePathDict["exakat"] = PATH_SCAN_RESULT_EXAKAT
            elif scanner == "phpcs":
                filePathDict["phpcs"] = PATH_SCAN_RESULT_PHPCS
            elif scanner == "progpilot":
                filePathDict["progpilot"] = PATH_SCAN_RESULT_PROGPILOT
            elif scanner == "rips":
                filePathDict["rips"] = PATH_SCAN_RESULT_RIPS
            elif scanner == "sonarsource":
                filePathDict["sonarsource"] = PATH_SCAN_RESULT_SONARSOURCE

    return filePathDict


def convertToJSON(listVuln):
    retList = []
    for vuln in listVuln:
        retList.append([vuln.filepath, vuln.line, vuln.vulnType.name])
    return json.dumps(retList)

# Ref: https://exakat.readthedocs.io/en/latest/Rulesets.html#security
def parseExakat(input_path):
    foundVulnerabilities = []
    # Read scan results from sqlite db file
    if not os.path.exists(input_path):
        printError("ERROR: Sqlite file not found in " + input_path)
        sys.exit(1)

    # Filter results for security related findings
    query = "SELECT file, line, analyzer " \
      "FROM results " \
      "WHERE analyzer LIKE 'Security/%'"

    # Open db connection
    db_connection = sqlite3.connect(input_path)
    cursor = db_connection.cursor()
    cursor.execute(query)

    XSS_FINDING = ["Security/DirectInjection", "Security/IndirectInjection"]
    SQLI_FINDING = ["Security/ShouldUsePreparedStatement",
       "Security/Sqlite3RequiresSingleQuotes"]
    CSRF_FINDING = []
    RCE_FINDING = ["Structures/EvalUsage", "Security/UnserializeSecondArg"]
    XXE_FINDING = ["Security/NoNetForXmlLoad"]

    # One security related finding each row
    for row in cursor:
        filepath = row[0]
        line = row[1]
        finding = row[2]

        # Specify found vuln type
        if finding in XSS_FINDING:
            finding = VulnType.XSS
        elif finding in SQLI_FINDING:
            finding = VulnType.SQLI
        elif finding in CSRF_FINDING:
            finding = VulnType.CSRF
        elif finding in RCE_FINDING:
            finding = VulnType.RCE
        elif finding in XXE_FINDING:
            finding = VulnType.XXE
        else:
            finding = VulnType.OTHER

        newVuln = Vulnerability(filepath, line, finding)
        foundVulnerabilities.append(newVuln)
    
    # Print result
    for vuln in foundVulnerabilities:
        print(vuln)

    # Export result as JSON
    with open(PATH_EXPORT_RESULT, "w") as f:
        f.write(convertToJSON(foundVulnerabilities))


def parsePhpcs(input_path):
    foundVulnerabilities = []
    # Read scan results from JSON file
    if not os.path.exists(input_path):
        printError("ERROR: JSON file not found in " + input_path)
        sys.exit(1)
   
    # One vulnerability in each row, ignore first (csv header)
    with open(input_path, 'r') as f:
            parsedJSON = json.loads(f.read())
            
            for file in parsedJSON["files"]:
                for message in parsedJSON["files"][file]["messages"]:
                    finding = message["source"]
                    line = message["line"]

                    XSS_FINDING = ["EasyXSSwarn", "EasyXSSerr"]
                    SQLI_FINDING = ["ErrMysqli", "WarnMysqli", "ErrMysqliconnect", "ErrSQLFunction"]
                    CSRF_FINDING = []
                    RCE_FINDING = ["ErrFunctionHandling", "WarnFunctionHandling", "ErrSystemExec", "WarnSystemExec", "WarnCallbackFunctions", "ErrCallbackFunctions", "ErrEasyRFI", "WarnEasyRFI", "NoEvals"]
                    XXE_FINDING = ["CVE-2013-4113"]

                    # Finding is something like this:
                    # PHPCS_SecurityAudit.BadFunctions.EasyXSS
                    # We just want the last part (EasyXSS in this example)
                    finding = finding.split(".")[-1]

                    # Specify found vuln type
                    if finding in XSS_FINDING:
                        finding = VulnType.XSS
                    elif finding in SQLI_FINDING:
                        finding = VulnType.SQLI
                    elif finding in CSRF_FINDING:
                        finding = VulnType.CSRF
                    elif finding in RCE_FINDING:
                        finding = VulnType.RCE
                    elif finding in XXE_FINDING:
                        finding = VulnType.XXE
                    else:
                        finding = VulnType.OTHER

                    newVuln = Vulnerability(file, line, finding)
                    foundVulnerabilities.append(newVuln)
            
    # Print result
    for vuln in foundVulnerabilities:
        print(vuln)

    # Export result as JSON
    with open(PATH_EXPORT_RESULT, "w") as f:
        f.write(convertToJSON(foundVulnerabilities))


def parseProgpilot(input_path):
    foundVulnerabilities = []
    # Read scan results from JSON file
    if not os.path.exists(input_path):
        printError("ERROR: JSON file not found in " + input_path)
        sys.exit(1)

    # One vulnerability in each dict entry
    with open(input_path, 'r') as f:
        parsedJSON =  json.loads(f.read())
        for vuln in parsedJSON:
            # distinguish between two different formats in entry
            if "sink_file" in vuln:
                finding = vuln["vuln_name"]
                line = vuln["sink_line"]
                file = vuln["source_file"][0]
            elif "vuln_file" in vuln:
                finding = vuln["vuln_name"]
                line = vuln["vuln_line"]
                file = vuln["vuln_file"]
            else:
                printWarning("Warning: Unrecognized entry in JSON")
                continue

            # Ref: progpilot-master\package\src\uptodate_data\php\sinks.json
            XSS_FINDING = ["xss"]
            SQLI_FINDING = ['sql_injection']
            CSRF_FINDING = []
            RCE_FINDING = ['code_injection', 'w32api command_injection', 'mail command_injection', 'command_injection']
            XXE_FINDING = ['xml_injection']

            # Specify found vuln type
            if finding in XSS_FINDING:
                finding = VulnType.XSS
            elif finding in SQLI_FINDING:
                finding = VulnType.SQLI
            elif finding in CSRF_FINDING:
                finding = VulnType.CSRF
            elif finding in RCE_FINDING:
                finding = VulnType.RCE
            elif finding in XXE_FINDING:
                finding = VulnType.XXE
            else:
                finding = VulnType.OTHER

            newVuln = Vulnerability(file, line, finding)
            foundVulnerabilities.append(newVuln)

        # Print result
        for vuln in foundVulnerabilities:
            print(vuln)

        # Export result as JSON
        with open(PATH_EXPORT_RESULT, "w") as f:
            f.write(convertToJSON(foundVulnerabilities))


def parseRips(input_path):
    foundVulnerabilities = []
    # Read scan results from JSON file
    if not os.path.exists(input_path):
        printError("ERROR: JSON file not found in " + input_path)
        sys.exit(1)

    with open(input_path, 'r') as f:
        parsedJSON = json.loads(f.read())

        # Each entry is a vuln file with its vulnerabilities as an array
        for vulnFile in parsedJSON:
            for vuln in parsedJSON[vulnFile]:
                if not vuln["vuln"]:
                    continue
                finding = vuln["category"]
                line = vuln["treenodes"][0]["lines"][0]

                XSS_FINDING = ["Cross-Site Scripting"]
                SQLI_FINDING = ["SQL Injection"]
                CSRF_FINDING = []
                RCE_FINDING = ["Code Execution", "Command Execution"]
                XXE_FINDING = []

                # Specify found vuln type
                # Ref: rips-v055\config\sinks.php
                if finding in XSS_FINDING:
                    finding = VulnType.XSS
                elif finding in SQLI_FINDING:
                    finding = VulnType.SQLI
                elif finding in CSRF_FINDING:
                    finding = VulnType.CSRF
                elif finding in RCE_FINDING:
                    finding = VulnType.RCE
                elif finding in XXE_FINDING:
                    finding = VulnType.XXE
                else:
                    finding = VulnType.OTHER

                newVuln = Vulnerability(vulnFile, line, finding)
                foundVulnerabilities.append(newVuln)

        # Print result
        for vuln in foundVulnerabilities:
            print(vuln)

        # Export result as JSON
        with open(PATH_EXPORT_RESULT, "w") as f:
            f.write(convertToJSON(foundVulnerabilities))


def parseSonarsource(input_path):
    foundVulnerabilities = []
    # Read scan results from JSON file
    if not os.path.exists(input_path):
        printError("ERROR: JSON file not found in " + input_path)
        sys.exit(1)

    # One vulnerability in each dict entry
    with open(input_path, 'r') as f:
        parsedJSON =  json.loads(f.read())
        for vuln in parsedJSON["hotspots"]:
            finding = vuln["securityCategory"]
            if "line" in vuln:
                line = vuln["line"]
            else:
                # Unspecified
                line = -1
            file = vuln["component"].split("scan_result:")[1]

            # Ref: progpilot-master\package\src\uptodate_data\php\sinks.json
            XSS_FINDING = ["xss"]
            SQLI_FINDING = ['sql-injection']
            CSRF_FINDING = []
            RCE_FINDING = ["command-injection", "rce"]
            XXE_FINDING = ['xxe']

            # Specify found vuln type
            if finding in XSS_FINDING:
                finding = VulnType.XSS
            elif finding in SQLI_FINDING:
                finding = VulnType.SQLI
            elif finding in CSRF_FINDING:
                finding = VulnType.CSRF
            elif finding in RCE_FINDING:
                finding = VulnType.RCE
            elif finding in XXE_FINDING:
                finding = VulnType.XXE
            else:
                finding = VulnType.OTHER

            newVuln = Vulnerability(file, line, finding)
            foundVulnerabilities.append(newVuln)

        # Print result
        for vuln in foundVulnerabilities:
            print(vuln)

        # Export result as JSON
        with open(PATH_EXPORT_RESULT, "w") as f:
            f.write(convertToJSON(foundVulnerabilities))

if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-s", "--scanner", help="Define one or more scanner(s) to parse their results (exakat, phpcs, progpilot, rips, sonarsource, all). Choosing 'all' will parse all scanner results", nargs='+', required=True)
    parser.add_argument("-i", "--input", help="Define path(s) containing scan results of selected scanners. Number of selected scanners through -s must match number of given input paths. If this option is not used, default paths will be used", nargs='+', required=False)
    args = parser.parse_args()
    
    # Create dictionary for scanner and the respective scan result file path
    lstFiles = getFilePaths(args.input, args.scanner)
    # Check if given paths exist
    for _, resultPath in lstFiles.items():
        if not os.path.exists(resultPath):
            printError(f"ERROR: Bad input path given: {resultPath}")
            sys.exit(1)

    if args.scanner[0] == "all":
        selectedScanners = ["exakat", "phpcs", "progpilot", "rips", "sonarsource"]
    else:
        selectedScanners = args.scanner

    for scanner in selectedScanners:
        if scanner == "exakat":
            parseExakat(lstFiles["exakat"])
        elif scanner == "phpcs":
            parsePhpcs(lstFiles["phpcs"])
        elif scanner == "progpilot":
            parseProgpilot(lstFiles["progpilot"])
        elif scanner == "rips":
            parseRips(lstFiles["rips"])
        elif scanner == "sonarsource":
            parseSonarsource(lstFiles["sonarsource"])
        else:
            printError(f"ERROR: Unknown scanner specified: {scanner}\nUse -h for help")
            sys.exit(1)


    
