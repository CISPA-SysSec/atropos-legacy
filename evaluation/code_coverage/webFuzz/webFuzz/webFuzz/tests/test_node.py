"""
pytest tests/test_node.py -v
"""
import pytest
from unittest.mock import patch, mock_open
from dataclasses import dataclass

from webFuzz.node import Node, calc_weighted_difference, parse_file, parse_headers, to_bucket, CFGTuple
from webFuzz.types import HTTPMethod

@pytest.mark.parametrize('headers, expected_out',
                        [
                            ({ 'I-1234': '324',
                              'something': 'okay',
                              'I-234': '432',
                              'I-432': '543',
                              'content-type': 'txt',
                            },
                            {
                                1234: '324',
                                234: '432',
                                432: '543'
                            })
                        ])
def test_parse_headers(headers, expected_out):
    actual_out = dict(parse_headers(headers))
    assert expected_out == actual_out

@pytest.mark.parametrize('file_contents, expected_out', 
                        [
                            ("228253266-13-0\n223121378-0-1\n26380490-1-50\n120901435-1-1\n170610950-9-0\n",
                            {
                                  228253266: '13-0', 
                                  223121378: '0-1', 
                                  26380490: '1-50', 
                                  120901435: '1-1', 
                                  170610950: '9-0' 
                            })
                        ])
def test_parse_file(file_contents, expected_out):
   with patch("builtins.open", mock_open(read_data=file_contents)):
      actual_out = parse_file("can be anything")
      assert expected_out == dict(actual_out)

@pytest.mark.parametrize('input_, expected_out', 
                        [
                            (456, 8),
                            (120, 7),
                            (30, 5),
                            (1, 0)
                        ])
def test_to_bucket(input_, expected_out):
    actualOut = to_bucket(input_)
    assert expected_out == actualOut

@pytest.mark.parametrize('value1, value2, weight, expected_out', 
                        [
                            (10,  5, 0.5, 2.5/7.5),
                            (30, 20, 0.5, 5/25),
                            (20, 30, 0.5, -5/25),
                        ])
def test_weighted_difference(value1, value2, weight, expected_out):
    actualOut = calc_weighted_difference(value1, value2, weight)
    assert expected_out == actualOut

@pytest.mark.parametrize('instrument_args, headers, expected_out',
                        [
                            ({
                                'output-method': 'http',
                                'instrument-type': 'aflplus',
                            },
                            { 'I-1234': '324-43',
                              'something': 'okay',
                              'I-234': '432-98',
                              'I-432': '543-11',
                              'content-type': 'txt',
                            },
                            CFGTuple(xor_cfg={
                                1234: to_bucket(324),
                                234: to_bucket(432),
                                432: to_bucket(543),
                            }, single_cfg={
                                1234: to_bucket(43),
                                234: to_bucket(98),
                                432: to_bucket(11)
                            })),
                            ({
                                'output-method': 'http',
                                'instrument-type': 'afl',
                            },
                            { 'I-1234': '324',
                              'something': 'okay',
                              'I-234': '432',
                              'I-432': '543',
                              'content-type': 'txt',
                            },
                            CFGTuple(xor_cfg={
                                1234: to_bucket(324),
                                234: to_bucket(432),
                                432: to_bucket(543),
                            }, single_cfg={}))
                        ])
def test_parse_instrumentation_header(instrument_args, headers, expected_out):
    actual_out = Node.parse_instrumentation(instrument_args, "", headers)
    assert actual_out== expected_out

@pytest.mark.parametrize('instrument_args, file_contents, expected_out',
                        [
                            ({
                                'output-method': 'file',
                                'instrument-type': 'aflplus',
                            },
                            '1234-324-43\n234-432-98\n432-543-11\n',
                            CFGTuple(xor_cfg={
                                1234: to_bucket(324),
                                234: to_bucket(432),
                                432: to_bucket(543),
                            }, single_cfg={
                                1234: to_bucket(43),
                                234: to_bucket(98),
                                432: to_bucket(11)
                            })),
                            ({
                                'output-method': 'file',
                                'instrument-type': 'afl',
                            },
                            '1234-324\n234-432\n432-543\n',
                            CFGTuple(xor_cfg={
                                1234: to_bucket(324),
                                234: to_bucket(432),
                                432: to_bucket(543),
                            }, single_cfg={}))
                        ])
def test_parse_instrumentation_file(instrument_args, file_contents, expected_out):
    with patch("builtins.open", mock_open(read_data=file_contents)):
        actual_out = Node.parse_instrumentation(instrument_args, "", {})
        assert actual_out== expected_out

@dataclass
class NodeMetrics():
    cover_score_xor: int = 0
    exec_time: float = 0
    size: int = 0
    picked_score: int = 0
    cover_score_parent: int = 0

@pytest.mark.parametrize('nodeMetrics1, nodeMetrics2, expected_out',
                        [
                            (NodeMetrics(cover_score_xor=500,
                                         cover_score_parent=500),
                             NodeMetrics(cover_score_xor=200,
                                         cover_score_parent=200),
                             True),
                            (NodeMetrics(exec_time=10),
                             NodeMetrics(exec_time=5),
                             False),
                            (NodeMetrics(size=10),
                             NodeMetrics(size=5),
                             False),
                            (NodeMetrics(picked_score=10),
                             NodeMetrics(picked_score=5),
                             False),
                            (NodeMetrics(cover_score_xor=1000,
                                         cover_score_parent=500),
                             NodeMetrics(cover_score_xor=800,
                                         cover_score_parent=500),
                             True),
                        ])
def test_Node_lt(nodeMetrics1, nodeMetrics2, expected_out):
    node1 = Node(url="n/a", method=HTTPMethod.GET)
    node2 = Node(url="n/a", method=HTTPMethod.GET)

    node1.cover_score_xor = nodeMetrics1.cover_score_xor
    node1.exec_time = nodeMetrics1.exec_time
    node1.picked_score = nodeMetrics1.picked_score
    node1._cover_score_parent = nodeMetrics1.cover_score_parent

    node2.cover_score_xor = nodeMetrics2.cover_score_xor
    node2.exec_time = nodeMetrics2.exec_time
    node2.picked_score = nodeMetrics2.picked_score
    node2._cover_score_parent = nodeMetrics2.cover_score_parent

    actual_out = node1 < node2
    assert expected_out == actual_out
