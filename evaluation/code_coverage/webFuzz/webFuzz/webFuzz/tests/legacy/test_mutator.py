import pytest
import copy

from unittest.mock import Mock, patch

import webFuzz.mutator  as m
from webFuzz.types      import HTTPMethod
from webFuzz.node       import Node

PREPEND = 5
APPEND = 2
STRING = 5
INT = 2
TAKE = 2
SKIP = 0

# TODO: Try to Simplify this test suite


# to run this test do
# cd 'web_fuzzer' and run: python -m unittest tests.test_mutator -v

class TestMutatorMethods(unittest.TestCase):
    def setUp(self):
        self.mutator = mut.Mutator()

        # manually patch random_string function
        mut.random_string = lambda len: 'v' * len

        self.mutator.xss_payloads = ['<script>alert(2)</script>',
                                     '<btn onclick="alert(2)"/>',
                                     '<click>alert(23)</click', ]
        mnode1 = Mock()
        mnode1.get_url.return_value = "http://localhost/wp-admin/index.php"
        mnode1.get_method.return_value = Http_method.POST
        mnode1.get_cover_score.return_value = 0
        mnode1.get_params.return_value = { Http_method.GET: { 'a1': ["1","2","3"], 'b1': 'hello' + self.mutator.xss_payloads[0]},
                                           Http_method.POST: { 'a1': ['ouk','lala'], 'b1':  self.mutator.xss_payloads[1] + 'there', 'c1': ['hihi']}}
        mnode1.get_xss_params.return_value = { Http_method.GET: set([('b1', 0)]),
                                              Http_method.POST: set([('b1', 1)]) }


        mnode2 = Mock()
        mnode2.get_url.return_value = "http://localhost/wp-admin/index.php"
        mnode2.get_method.return_value = Http_method.POST
        mnode2.get_cover_score.return_value = 0
        mnode2.get_params.return_value = { Http_method.GET: { 'a2': ["0"], 'b2': '+++++' + self.mutator.xss_payloads[0]},
                                           Http_method.POST: { 'a2': ['ouk','lala'], 'b2':  self.mutator.xss_payloads[1] + '____', 'c2': ['x0x0']}}
        mnode2.get_xss_params.return_value = { Http_method.GET: set([('b2', 0)]),
                                              Http_method.POST: set([('b2', 1)]) }
        mnode3 = Mock()
        mnode3.get_url.return_value = "http://localhost/wp-login.php"
        mnode3.get_method.return_value = Http_method.GET
        mnode3.get_cover_score.return_value = 0
        mnode3.get_params.return_value = { Http_method.GET: { 'a3': ["1","2","3"], 'b3': 'hello' + self.mutator.xss_payloads[1]},
                                          Http_method.POST: { 'a3': ["45"]}}
        mnode3.get_xss_params.return_value = { Http_method.GET: set([('b3', 1)]),
                                               Http_method.POST: set() }

        mnode4 = Mock()
        mnode4.get_url.return_value = "http://localhost/"
        mnode4.get_method.return_value = Http_method.POST
        mnode4.get_cover_score.return_value = 0
        mnode4.get_params.return_value = { Http_method.GET: { 'a4': ["1","2","3"], 'b4': 'hello' + self.mutator.xss_payloads[1]},
                                          Http_method.POST: { 'a4': ['ouk','lala'], 'b1': self.mutator.xss_payloads[2] + 'there'}}
        mnode4.get_xss_params.return_value = { Http_method.GET: set([('b4', 1)]),
                                              Http_method.POST: set([('b1', 2)]) }

        self.node_list = [mnode1, mnode2, mnode3, mnode4]

    def test_alter_param_type_to_list(self):
        (new_p, new_v) = self.mutator.alter_type('b1', 'nottobechanged')
        self.assertEqual('b1[]', new_p)
        self.assertEqual('nottobechanged', new_v)

    def test_alter_param_type_to_str(self):
        (new_p, new_v) = self.mutator.alter_type('b1[]', 'nottobechanged')
        self.assertEqual('b1', new_p)
        self.assertEqual('nottobechanged', new_v)

    def test_alter_param_type_2d_to_1d(self):
        (new_p, new_v) = self.mutator.alter_type('b1[one][two]', 'nottobechanged')
        self.assertEqual('b1[one]', new_p)
        self.assertEqual('nottobechanged', new_v)

    def test_add_random_text_prepend_str(self):
        rand_order = [PREPEND,4,STRING]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.add_random_text('nottobechanged', 'okay')
            self.assertEqual('nottobechanged', new_p)
            self.assertEqual(['vvvvokay'], new_v)

    def test_add_random_text_append_str(self):
        rand_order = [APPEND,4,STRING]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.add_random_text('nottobechanged', 'okay')
            self.assertEqual('nottobechanged', new_p)
            self.assertEqual(['okayvvvv'], new_v)

    def test_add_random_text_prepend_int(self):
        rand_order = [PREPEND,54,INT]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.add_random_text('nottobechanged', 'okay')
            self.assertEqual('nottobechanged', new_p)
            self.assertEqual(['54okay'], new_v)

    def test_add_random_text_append_int(self):
        rand_order = [APPEND,54,INT]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.add_random_text('nottobechanged', 'okay')
            self.assertEqual('nottobechanged', new_p)
            self.assertEqual(['okay54'], new_v)

    def test_add_syntax_token_prepend(self):
        choice_order = ['<token>','<hello>']
        mocked_random_choice = lambda _: choice_order.pop()
        rand_order = [PREPEND]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            with patch('random.choice', mocked_random_choice):
                (new_p, new_v) = self.mutator.add_syntax_token('nottobechanged', 'okay')
                self.assertEqual('nottobechanged', new_p)
                self.assertEqual(['<hello><token>okay'], new_v)

    def test_add_syntax_token_append(self):
        choice_order = ['<token>','<hello>']
        mocked_random_choice = lambda _: choice_order.pop()
        rand_order = [APPEND]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            with patch('random.choice', mocked_random_choice):
                (new_p, new_v) = self.mutator.add_syntax_token('nottobechanged', 'okay')
                self.assertEqual('nottobechanged', new_p)
                self.assertEqual(['okay<hello><token>'], new_v)

    def test_insert_xss_payload_prepend(self):
        xss_params = set([('a1', 0)])
        rand_order = [PREPEND,1]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.insert_xss_payload('nottobechanged', 'okay', xss_params)
            self.assertEqual('nottobechanged', new_p)
            self.assertEqual(['<btn onclick="alert(2)"/>okay'], new_v)
            self.assertEqual(set([('a1', 0), ('nottobechanged', 1)]), xss_params)

    def test_insert_xss_payload_append(self):
        xss_params = set([('a1', 0)])
        rand_order = [APPEND,1]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.insert_xss_payload('nottobechanged', 'okay', xss_params)
            self.assertEqual('nottobechanged', new_p)
            self.assertEqual(['okay<btn onclick="alert(2)"/>'], new_v)
            self.assertEqual(set([('a1', 0), ('nottobechanged', 1)]), xss_params)

    def test_insert_xss_payload_prepend_list(self):
        xss_params = set([('a1', 0)])
        rand_order = [PREPEND,1]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.insert_xss_payload('nottobechanged', ['hi','okay'], xss_params)
            self.assertEqual('nottobechanged', new_p)
            self.assertEqual(['<btn onclick="alert(2)"/>hi', '<btn onclick="alert(2)"/>okay'], new_v)
            self.assertEqual(set([('a1', 0), ('nottobechanged', 1)]), xss_params)

    def test_insert_xss_payload_append_list(self):
        xss_params = set([('a1', 0)])
        rand_order = [APPEND,1]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.insert_xss_payload('nottobechanged', ['hi','okay'], xss_params)
            self.assertEqual('nottobechanged', new_p)
            self.assertEqual(['hi<btn onclick="alert(2)"/>', 'okay<btn onclick="alert(2)"/>'], new_v)
            self.assertEqual(set([('a1', 0), ('nottobechanged', 1)]), xss_params)

    def test_insert_xss_payload_too_many_xss_in_param(self):
        l = []
        for i in range(mut.MAX_XSS_PER_PARAM):
            l.append(('a1',i))

        xss_params = set(l)
        xss_params_orig = copy.deepcopy(xss_params)

        (new_p, new_v) = self.mutator.insert_xss_payload('a1', 'okay', xss_params)
        self.assertEqual('a1', new_p)
        self.assertEqual(['okay'], new_v)
        self.assertEqual(xss_params_orig, xss_params)

    def test_insert_xss_payload_not_too_many_xss_in_param(self):
        l = []
        for i in range(1 + int(mut.MAX_XSS_PER_PARAM/2)):
            l.append(('a1',i+3))
        for i in range(1 + int(mut.MAX_XSS_PER_PARAM/2)):
            l.append(('b1',i))

        xss_params = set(l)
        xss_params_orig = copy.deepcopy(xss_params)
        xss_params_orig.add(('a1', 1))

        rand_order = [APPEND,1]
        mocked_random_randrange = lambda _,__: rand_order.pop()
        with patch('random.randrange', mocked_random_randrange):
            (new_p, new_v) = self.mutator.insert_xss_payload('a1', 'okay', xss_params)
            self.assertEqual('a1', new_p)
            self.assertEqual(['okay<btn onclick="alert(2)"/>'], new_v)
            self.assertEqual(xss_params_orig, xss_params)

    def test_cross_over_non_overlapping_merge(self):
        choices_order = [self.mutator.all_param_mutate]
        mocked_random_choices = lambda l, weights, k: [choices_order.pop()]

        choice_order = [self.mutator.cross_over]
        mocked_random_choice = lambda _: choice_order.pop()

        # get param merge product of mnode1 and mnode3
        exp_get_params = { 'a1': ["1","2","3"], 'b1': 'hello' + self.mutator.xss_payloads[0], 'a3': ["1","2","3"], 'b3': 'hello' + self.mutator.xss_payloads[1]}

        exp_get_xss_params =set([('b1', 0), ('b3', 1)])

        with patch('random.choices', mocked_random_choices):
            with patch('random.choice', mocked_random_choice):
                new_node = self.mutator.mutate(self.node_list[0], self.node_list)
                self.assertEqual(new_node.get_params()[Http_method.GET], exp_get_params)
                self.assertEqual(new_node.get_xss_params()[Http_method.GET], exp_get_xss_params)

    def test_cross_over_overlapping_merge(self):
        choices_order = [self.mutator.all_param_mutate]
        mocked_random_choices = lambda l, weights, k: [choices_order.pop()]

        choice_order = [self.mutator.cross_over]
        mocked_random_choice = lambda _: choice_order.pop()

        # post param merge product of mnode1 and mnode4
        exp_post_params = { 'a1': ['ouk','lala'], 'c1': ['hihi'], 'a4': ['ouk','lala'], 'b1': self.mutator.xss_payloads[2] + 'there'}

        exp_post_xss_params =set([('b1', 2)])

        with patch('random.choices', mocked_random_choices):
            with patch('random.choice', mocked_random_choice):
                new_node = self.mutator.mutate(self.node_list[0], self.node_list)
                self.assertEqual(new_node.get_params()[Http_method.POST], exp_post_params)
                self.assertEqual(new_node.get_xss_params()[Http_method.POST], exp_post_xss_params)

    def test_per_param_mutate_combo(self):
        choices_order = [self.mutator.per_param_mutate]
        mocked_random_choices = lambda l, weights, k: [choices_order.pop()]

        choice_order = [self.mutator.insert_xss_payload, self.mutator.alter_type, self.mutator.add_random_text]
        mocked_random_choice = lambda _: choice_order.pop()

        rand_order = [PREPEND, 1, TAKE, TAKE, APPEND, 4, STRING, TAKE]
        mocked_random_randrange = lambda _,__: rand_order.pop()

        # get param merge product of mnode1 and mnode4
        exp_get_params = { 'a3': ['1vvvv','2vvvv','3vvvv'], 'b3[]': 'hello' + self.mutator.xss_payloads[1]}
        exp_get_xss_params = set([('b3', 1)])

        exp_post_params = {'a3': ['<btn onclick="alert(2)"/>45'] }
        exp_post_xss_params =set([('a3', 1)])

        with patch('random.choices', mocked_random_choices):
            with patch('random.choice', mocked_random_choice):
                with patch('random.randrange', mocked_random_randrange):
                    new_node = self.mutator.mutate(self.node_list[2], self.node_list)
                    self.assertEqual(new_node.get_params()[Http_method.GET], exp_get_params)
                    self.assertEqual(new_node.get_xss_params()[Http_method.GET], exp_get_xss_params)
                    self.assertEqual(new_node.get_params()[Http_method.POST], exp_post_params)
                    self.assertEqual(new_node.get_xss_params()[Http_method.POST], exp_post_xss_params)


if __name__ == '__main__':
    unittest.main()
