.PHONY: help

code-check:
	mix format --check-formatted
	mix lint.credo
	mix deps.unlock --check-unused
