#!/bin/sh

test_description='git rebase of commits that start or become empty'

. ./test-lib.sh

test_expect_success 'setup test repository' '
	test_write_lines 1 2 3 4 5 6 7 8 9 10 >numbers &&
	test_write_lines A B C D E F G H I J >letters &&
	git add numbers letters &&
	git commit -m A &&

	git branch upstream &&
	git branch localmods &&

	git checkout upstream &&
	test_write_lines A B C D E >letters &&
	git add letters &&
	git commit -m B &&

	test_write_lines 1 2 3 4 five 6 7 8 9 ten >numbers &&
	git add numbers &&
	git commit -m C &&

	git checkout localmods &&
	test_write_lines 1 2 3 4 five 6 7 8 9 10 >numbers &&
	git add numbers &&
	git commit -m C2 &&

	git commit --allow-empty -m D &&

	test_write_lines A B C D E >letters &&
	git add letters &&
	git commit -m "Five letters ought to be enough for anybody"
'

test_expect_success 'rebase --merge --empty=drop' '
	git checkout -B testing localmods &&
	git rebase --merge --empty=drop upstream &&

	test_write_lines C B A >expect &&
	git log --format=%s >actual &&
	test_cmp expect actual
'

test_expect_success 'rebase --merge --empty=keep' '
	git checkout -B testing localmods &&
	git rebase --merge --empty=keep upstream &&

	test_write_lines D C2 C B A >expect &&
	git log --format=%s >actual &&
	test_cmp expect actual
'

test_expect_success 'rebase --merge --empty=ask' '
	git checkout -B testing localmods &&
	test_must_fail git rebase --merge --empty=ask upstream &&

	test_must_fail git rebase --skip &&
	git commit --allow-empty &&
	git rebase --continue &&

	test_write_lines D C B A >expect &&
	git log --format=%s >actual &&
	test_cmp expect actual
'

GIT_SEQUENCE_EDITOR=: && export GIT_SEQUENCE_EDITOR

test_expect_success 'rebase --interactive --empty=drop' '
	git checkout -B testing localmods &&
	git rebase --interactive --empty=drop upstream &&

	test_write_lines C B A >expect &&
	git log --format=%s >actual &&
	test_cmp expect actual
'

test_expect_success 'rebase --interactive --empty=keep' '
	git checkout -B testing localmods &&
	git rebase --interactive --empty=keep upstream &&

	test_write_lines D C2 C B A >expect &&
	git log --format=%s >actual &&
	test_cmp expect actual
'


test_done
