module main

import os

struct Line {
mut:
	num int
	content string
}

struct Variable {
mut:
	name string
	value f32
}

struct Context {
mut:
	lines []&Line
	vars []&Variable

	pc int = -1
}

fn get_line(num int, ctx &Context) ?string {
	for l in ctx.lines {
		if l.num == num {
			return l.content
		}
	}
	return none
}

fn goto_next_line(mut ctx &Context) {
	for {
		get_line(ctx.pc, ctx) or {
			ctx.pc ++
			continue
		}
		return
	}
}

fn exec(input string, mut ctx &Context) ?f32 {
	text := input.split(" ")
	if text.len == 0 || text[0].len == 0  {
		return none
	}

	if text[0].starts_with("æ") {
		return none
	}

	if text[0].starts_with("ø") {
		ln := text[0].after("ø").int()

		for mut l in ctx.lines {
			if ln == l.num {
				l.content = text[1..].join(" ")
				return none
			}
		}
		ctx.lines << &Line {
			num: ln
			content: text[1..].join(" ")
		}

		return none
	}

	if text[0].starts_with("¡") {
		vn := text[0].after("¡")
		v := exec(text[1..].join(" "), mut ctx) or {
			return none
		}

		for mut var in ctx.vars {
			if var.name == vn {
				var.value = v
				return none
			}
		}

		ctx.vars << &Variable {
			name: vn
			value: v
		}

		return none
	}

	if text[0].starts_with("¤") {
		ctx.pc = text[0].after("¤").int() - 1
		return none
	}

	if text[0].starts_with("¢") {
		vn := text[0].after("¢")
		for var in ctx.vars {
			if var.name == vn {
				return var.value
			}
		}
		println(ctx.vars)
		return none
	}

	match text[0] {
		"#--" {
			return os.input("> ").f32()
		}
		"--#" {
			println(exec(text[1], mut ctx)?)
		}
		"?" {
			if exec(text[1], mut ctx)? == exec(text[2], mut ctx)? {
				ctx.pc = text[3].int() - 1
			}
		}
		"-þ" {
			exit(0)
		}
		else {
			return text[0].f32()
		}
	}

	return none
}

fn main() {
	mut ctx := &Context {}

	if os.args.len != 2 {
		println("Invalid arguments!")
		return
	}

	for l in os.read_lines(os.args[1])! {
		exec(l, mut ctx)
	}

	for {
		goto_next_line(mut ctx)
		exec(get_line(ctx.pc, ctx)?, mut ctx)
		ctx.pc ++
	}
}
