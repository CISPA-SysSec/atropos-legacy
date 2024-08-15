import pytest
from unittest.mock import Mock, patch

import webFuzz.mutator     as m
from webFuzz.environment   import env
from webFuzz.node          import Node
from webFuzz.types         import HTTPMethod, Arguments, XssEntry

@pytest.fixture(scope='module')
def mutator():
    mutator_obj = m.Mutator()
    mutator_obj.xss_payloads = ['<script>alert(2)</script>',
                                '<btn onclick="alert(2)"/>',
                                '<click>alert(23)</click', ]
    yield mutator_obj

@pytest.mark.parametrize('payload, values, expected_values',
                         [
                             ("FUZZ", ['okay'], ['okayFUZZ']),
                             ("FUZZ", [""], ['FUZZ']),
                             ("FUZZ", ["okay", "hey"], ["okayFUZZ", "heyFUZZ"]),
                         ]
                         )
def test_add_random_text(payload, values, expected_values):
    mocked_random_string = lambda _: payload

    with patch('webFuzz.mutator.Mutator.random_string', mocked_random_string):
        with patch('random.randint', lambda _, __: m.TAILS):
            (param, actual_values) = m.Mutator.add_random_text('nottobechanged', values)
            assert 'nottobechanged' == param
            assert actual_values == expected_values

@pytest.mark.parametrize('token, values, expected_values',
                         [
                             ("<script", ['okay'], ['<scriptokay<script']),
                             ("<?php", [""], ['<?php<?php']),
                             ("if {}", ["okay", "hey"], ["if {}okayif {}", "if {}heyif {}"]),
                         ]
                         )
def test_add_syntax_token(mutator, token, values, expected_values):
    mutator.syntax_tokens = [token]

    (param, actual_values) = mutator.add_syntax_token('nottobechanged', values)
    assert 'nottobechanged' == param
    assert actual_values == expected_values

@pytest.mark.parametrize('param, expected_param',
                         [
                             ("pie", 'pie[]'),
                             ("pie[]", 'pie'),
                         ]
                         )
def test_alter_param_type(param, expected_param):
    (actual_param, value) = m.Mutator.alter_type(param, ['nottobechanged'])
    assert value == ['nottobechanged']
    assert actual_param == expected_param

@pytest.mark.parametrize('xss, param, values, xss_meta, expected_values, expected_xss_meta',
                         [
                             (
                                "<script>alert(1)</script>", 
                                'p1' ,
                                ['okay'], 
                                set(),
                                ['okay<script>alert(1)</script>'], 
                                set([XssEntry('p1', 0)])
                              ),
                              # 
                              (
                                "<script>alert(1)</script>", 
                                'p1' ,
                                ['okay'], 
                                set([XssEntry('p1', 0), XssEntry('p1', 1), XssEntry('p1', 2), XssEntry('p1', 3)]),
                                ['okay'], 
                                set([XssEntry('p1', 0), XssEntry('p1', 1), XssEntry('p1', 2), XssEntry('p1', 3)]),
                              ),
                         ]
                         )
def test_add_xss_payload(mutator, xss, param,values, xss_meta, expected_values, expected_xss_meta):
    env.args = Mock(wraps=Arguments)
    env.args.maxXss = 3
    mutator.xss_payloads = [xss]
      
    with patch('random.randint', lambda _, __: m.TAILS):
        (param, actual_values) = mutator.add_xss_payload('p1', values, xss_meta)
        assert 'p1' == param
        assert actual_values == expected_values
        assert xss_meta == expected_xss_meta 