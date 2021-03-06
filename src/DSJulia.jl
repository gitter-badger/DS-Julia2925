#=
Created on Friday 4 December 2020
Last update: Saturday 26 December 2020

@author: Michiel Stock
michielfmstock@gmail.com

@author: Bram De Jaegher
bram.de.jaegher@gmail.com

Templates heavily based on the MIT course "Computational Thinking"

https://computationalthinking.mit.edu/Fall20/installation/
=#

module DSJulia
    using Markdown
    using Markdown: MD, Admonition
    using PlutoUI

    export check_answer, still_missing, keep_working, correct, not_defined, hint, fyi  
    export Question, QuestionOptional, QuestionBlock, validate
    export NoDiff, Easy, Intermediate, Hard
    export ProgressTracker, grade
    export @safe
    export @terminal

    include("styles.jl")
    include("admonition.jl")
    include("question.jl")
    include("grading.jl")

    # Solutions
    export Solutions
    module Solutions
        using Colors, Images
        include("solutions.jl")
    end

    # Convenience macro for terminal printing in Pluto
    macro terminal(ex)
        return quote
            PlutoUI.with_terminal() do
                $(esc(ex))
            end
        end
    end
end