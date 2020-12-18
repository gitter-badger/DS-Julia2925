#=
Created on Friday 4 December 2020
Last update: -

@author: Michiel Stock
michielfmstock@gmail.com

@author: Bram De Jaegher
bram.de.jaegher@gmail.com

Automatic grading of answers in our Pluto notebook.
Templates heavily based on the MIT course "Computational Thinking"

https://computationalthinking.mit.edu/Fall20/installation/
=#

using Markdown
using Markdown: MD, Admonition

abstract type AbstractQuestion end

mutable struct ProgressTracker 
	correct::Int
	total::Int
	name::String
	email::String
	ProgressTracker(name, email) = return new(0, 0, name, email)
end

addQuestion!(t::ProgressTracker) = t.total += 1
accept!(t::ProgressTracker) =	t.correct += 1
Base.show(io::IO, t::ProgressTracker) = print(io, "Notebook of **$(t.name)** with a completion of **$(t.correct) out of $(t.total)** question(s).")

# --- Advanced Questions --- #
still_missing(text=md"Replace `missing` with your answer.") = MD(Admonition("warning", "Here we go!", [text]))
title_default = Markdown.MD(md"### Question 0.: /insert title here/")
description_default = Markdown.MD(md"""Complete the function `myclamp(x)` that clamps a number `x` between 0 and 1.
Open assignments always return `missing`.
""")
validators_default = missing
hints_default = Markdown.MD[]
status_default = [still_missing()]

mutable struct Question <:AbstractQuestion
	title::Markdown.MD
	description::Markdown.MD
	validators::Any
	hints::Array{Markdown.MD}
	status::Markdown.MD

	Question(;title=title_default,
						description=description_default,
						validators=validators_default,
						hints = hints_default) = return new(title, description, validators, hints, status_default)
end

Base.show(io::IO, ::MIME"text/html", q::AbstractQuestion) = print(io::IO, tohtml(q))

function tohtml(q::Question)
	hint_br = ""

	if length(q.hints) > 0
		hint_br = "<br> <p>Hints:</p>"
	end

	out = """
	$(html(q.title))
	<p> $(html(q.description)) </p>
	<p> $(html(q.status)) </p>
	$(hint_br)
	$(reduce(*,["<p>" * html(hint) * "</p>" for hint in q.hints]))
	"""
	return out
end

function validate(q::AbstractQuestion, t::ProgressTracker, statements...)
	addQuestion!(t)
	all_valid = all(statements)
	some_valid = any(statements)
	if ismissing(all_valid) 
		q.status = still_missing()
	elseif some_valid && !all_valid
		q.status = keep_working(MD("You are not quite there, but getting warmer!"))
	elseif !all_valid
		q.status = keep_working()
	elseif all_valid 
		accept!(t)
		q.status = correct()
		return q
	end 
end


# --- Autograder function --- #
"""
	Validates answer statements and updates question tracker
"""

function check_answer(t::ProgressTracker, statements...)
	addQuestion!(t)
	all_valid = all(statements)
	ismissing(all_valid) && return still_missing()
	some_valid = any(statements)
	some_valid && !all_valid && return keep_working(MD("You are not quite there, but getting warmer!"))
	!all_valid && return keep_working()
	if all_valid 
		accept!(t)
		return correct()
	end 
end

function grade(fn)
	open(fn, "a") do f
    write(f, "\ntracker\n")
	end
	include(fn)
	return tracker
end

# --- Admonition options --- #
still_missing(text=md"Replace `missing` with your answer.") = MD(Admonition("warning", "Here we go!", [text]))

hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]))

keep_working(text=md"The answer is not quite right.") = MD(Admonition("danger", "Keep working on it!", [text]))

yays = [md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!",
        md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!",
				md"Let's move on to the next section."]
				
correct(text=rand(yays)) = MD(Admonition("correct", "Got it!", [text]))

not_defined(variable_name) = MD(Admonition("danger", "Oopsie!", [md"Make sure that you define a variable called **$(Markdown.Code(string(variable_name)))**"]))

# --- Non-checking admonitions --- #
fyi(text) = Markdown.MD(
	Markdown.Admonition("info",
		"Additional info",
		[html"""
			<style> pluto-output div.admonition.info .admonition-title {
						background: rgb(161, 161, 161);
					} 

					pluto-output div.admonition.info {
						background: rgba(161, 161, 161, 0.2);
						border: 5px solid rgb(161, 161, 161);
					}
			</style>
		""",
			text
		]
	)
)

bomb(text) = Markdown.MD(
	Markdown.Admonition("bomb",
		"Self destruct warning",
		[html"""
			<style> pluto-output div.admonition.bomb .admonition-title {
						background: rgb(226, 157, 148);
						animation:blinkingBox 1.5s infinite;
					} 

					pluto-output div.admonition.bomb {
						background: rgba(226, 157, 148, 0.2);
						border: 5px solid rgb(226, 157, 148);
						animation:blinkingBox 1.5s infinite;
					}

			@keyframes blinkingBox{
				0%{     visibility: hidden;    }
				30%{    visibility: hidden; }
				31%{    visibility: visible; }
				99%{    visibility: visible;  }
				100%{   visibility: hidden;     }
			}
			</style>
		""",
			text
		]
	)
)



