#lang scribble/manual
@(require "lib.rkt")
@(mint-scope "overview")

@title[#:version reach-vers #:tag "overview"]{Overview}

This is an informal overview of Reach and the structure of a Reach program.
The goal of this document is to give enough technical specifics to help you understand what Reach does, but it isn't intended as either a @seclink["tut"]{tutorial} or a @seclink["ref"]{reference}.
When you're ready to really begin a project, you can start with one of those, or @seclink["workshop"]{the workshop}.

If you have experience with blockchain development using existing tools, we recommend reading this article and @seclink["guide-solidity"]{a comparision with other development platforms}.

@margin-note{A recording of a live workshop that goes over this material is @link["https://www.youtube.com/watch?v=1jmi8XdOvD4"]{available on YouTube}.}

@section[#:tag "over-model"]{Decentralized applications}

@DApps are made of multiple agents interacting with each other through some backend @tech{consensus network}, like Ethereum or Algorand.
These agents act on behalf of principals that provide direction and authority through information.
These principals might be humans or other autonomous agents or even committees and organizations with their own structure.
The consensus network allows these agents to transfer and receive value in the form of network-specific tokens, like ETH or ALGO.
The network also allows the creation of "contracts" that ensure that all agents follow the same rules as they take turns computing and publishing values and information.
The details of these "contracts" are specific to each consensus network, but they are implicitly trusted by all agents and principals, because their operation can be independently verified to match the previously agreed-upon rules.

A single Reach program incorporates all aspects of a @|DApp|:
@itemlist[

@item{@tech{Participant} @tech{backends} are the agents acting on behalf of the principals.}

@item{@tech{Frontends} are the technical representation of the interface between the @tech{participants} and the principals.}

@item{A @tech{contract} enforces the rules of the program, including the order of operation.}

]

In Reach, a programmer only needs to specify the actions of @tech{participants}---what they do individually and what they do in unison.
The Reach compiler automatically derives a @tech{contract} for the @tech{consensus network} via a @tech{connector} that enforces these rules.

@section[#:tag "over-minimal"]{A minimal Reach program}

Let's look at a simple Reach program where two principals, Alice and Bob, interact. In this @|DApp|, Alice has some information that Bob might want and she has an amount of network tokens in mind that she'd like to trade for it.

@margin-note{You can look at the entire example program by visiting @reachexlink["overview/index.rsh"].}
@margin-note{Get language support for Reach in your editor by visiting @seclink["guide-editor-support"].}

The main part of the program looks like this:

@reachex[#:show-lines? #t "overview/index.rsh"
         'skip 12 30 "      // ...body..."]

@itemlist[

@item{Line 1 specifies that this is a Reach program.}

@item{Line 2 specifies that this program will be compiled with @tech{strict mode}, which enables unused variable checks.}

@item{Line 4 defines the main @tech{export} from program. @litchar{main} is the default used by Reach.}

@item{Line 5 specifies that it is an application.}

@item{Lines 7 and 8 specify the interface between Alice's @tech{participant} and @tech{frontend}. In this case, Alice's @tech{frontend} must provide a number called @litchar{request} and a string called @litchar{info}.}

@item{Lines 9 and 10 specify the interface for Bob, which includes a function named @litchar{want}, that takes a number and returns @reachin{null}, as well as a function named @litchar{got}, that receives the information.}

@item{Finally, line 11, binds these @tech{participants} to the program identifiers @reachin{A} and @reachin{B}.}

]

The elided lines, 12 through 30, contain the body of the application, which we can divide into four parts.

@reachex[#:show-lines? #t "overview/index.rsh"
         'only 12 15 "      // ..."]

@itemlist[

@item{Lines 12 and 13 specify that Alice takes a @tech{local step} where she @tech{declassifies} the amount of tokens requested.
In Reach, all values from the @tech{frontend} are @tech{secret} until explicitly made @tech{public} with @tech{declassify}.}

@item{Line 14 has Alice @tech{joins} the application by publishing that value and the logic of the program transitions to specifying what the @tech{contract} does.}

@item{Line 15 has the @tech{contract} commit to these values and continue the rest of the program.}

]

At this point, Bob's @tech{backend} has learned the value of @reachin{request} and can deliver it to Bob's @tech{frontend} for his approval. This happens next.

@reachex[#:show-lines? #t "overview/index.rsh"
         'only 17 20 "      // ..."]

@itemlist[

@item{Lines 17 and 18 has Bob perform that delivery.
@reachin{interact.want} doesn't explicitly return a boolean, because the frontend can not return if Bob doesn't want to continue.
A better version of this program might return @reachin{false} and have that communicated to Alice.}

@item{Lines 19 and 20 have Bob @tech{join} the application and submit a payment matching the appropriate amount and then the @tech{contract} commits.}

]

It's now Alice's turn again,

@reachex[#:show-lines? #t "overview/index.rsh"
         'only 22 26 "      // ..."]

@itemlist[

@item{Lines 22 and 23 specify that Alice @tech{declassifies} the information.}

@item{Line 24 has her publish it.}

@item{Line 25 has the @tech{contract} transfer the requested amount to her.}

@item{Line 26 commits the transactions on the @tech{consensus network}.}

]

The only thing left is for Bob's @tech{backend} to deliver the information to his @tech{frontend}.

@reachex[#:show-lines? #t "overview/index.rsh"
         'only 28 30 "      // ..."]

@itemlist[

@item{Line 28 and 29 do this.}

@item{Line 30 exits the program.}

]

@(hrule)

Reach programmers don't need to think about details like @emph{contract storage}, @emph{protocol diagrams}, @emph{state validation}, or @emph{network details}; instead, they can focus exclusively on the business logic of their application.

@section[#:tag "over-compile"]{Compile}

After a Reach programmer writes this application in a file like @reachexlink["overview/index.rsh" @exec{overview/index.rsh}], they could run

@cmd{reach compile @reachexlink["overview/index.rsh"]}

and the @exec{build} directory will contain a new file named @reachexlink["overview/build/index.main.mjs" @exec{index.main.mjs}], which contains a JavaScript implementation of a @tech{backend} for each participant, as well as the Ethereum bytecode for the @tech{contract}.

@margin-note{If you are curious, you can take a look at this file by going to @reachexlink["overview/build/index.main.mjs"].
The Ethereum bytecode is not readable, but if you understand Solidity, you may want to look at @reachexlink["overview/build/index.main.sol"] to see the original Solidity source that it is compiled from.
Reach can leave files like these in place when run with @DFlag{intermediate-files}.}

For this @exloc["overview/index.rsh"] line application, the Reach compiler generated @exloc["overview/build/index.main.mjs" -152] lines of JavaScript code in two functions, one for Alice and one for Bob.
Separately, it generated @exloc["overview/build/index.main.sol"] lines of Solidity code to implement the contract.
If a programmer wasn't using Reach, they would have to write these @exloc["overview/build/index.main.mjs" "overview/build/index.main.sol" -152] lines in these three modules separately and keep them synchronized at every step of the development process.

Moreover, Reach doesn't only work for Ethereum: it is blockchain agnostic and can be easily configured to use a different @tech{connector} to target other @tech{consensus networks}, like Algorand.
Nor is Reach tied to JavaScript, it can be configured to target other @tech{backend} languages, like Go.

@section[#:tag "over-verify"]{Verify}

Reach doesn't just compile your program, it also verifies it and ensures that entire categories of errors don't occur.
For example, it always guarantees that the balance in the @tech{contract} at the end of the program is zero.
This is important, because if it were not true, then tokens would be locked away by the @tech{contract} and inaccessible.

For this example program, it is obvious that when a single transfer of @reachin{request} goes in at line 18 and a single transfer of @reachin{request} goes out at line 24, then the balance is zero at the end of the program.
We could make a small tweak, however, to demonstrate things going wrong.

Let's change the third step to leave a single unit in the balance:

@reachex[#:show-lines? #t "overview/index-error.rsh"
         'only 21 25 "      // ..."]

And then run the compiler

@cmd{reach compile @reachexlink["overview/index-error.rsh"]}

It will print out a detailed error message showing the violation.

@reachex[#:mode verbatim
         #:show-lines? #t "overview/index-error.txt"
         'only 2 16 "// ..."]

Verification failures include a lot of information, such as a concrete counter-example showing values that could have been provided by @tech{frontends} that would lead to the property failing to hold.
In this case, it reports that if Alice were to pass an @reachin{interact.request} over @reachin{1} at the start of the program on line 4, then the balance of the contract would not be provably @reachin{0} at the end of the program.

@(hrule)

Reach programmers don't need to be worried about entire categories of errors, because the compiler automatically checks their code and ensures that those errors aren't present.
Of course, there's a lot more to say about the details of @seclink["guide-assert"]{automatic verification}; indeed, it is one of the most powerful features of Reach, but we'll leave it at that for now.

@section[#:tag "over-interface"]{Interface}

The backend produced by the Reach compiler isn't an application on its own.
In particular, each @tech{participant} needs a @tech{frontend} to interact with.
In a real deployment, this interfacing code would be tied to a GUI, like a Web or smartphone app.
Let's look at a simple command-line version that demonstrates how it would work for testing on a private devnet.

@margin-note{You can look at the entire example interface program by visiting @reachexlink["overview/index.mjs"].}

The program is just @exloc["overview/index.mjs"] lines long and the shell of it is quite simple:

@reachex[#:mode js
         #:show-lines? #t "overview/index.mjs"
         'skip 14 21 "    // ..."]

@itemlist[

@item{Lines 1 and 2 import the Reach standard library loader and the compiled app backend.}

@item{Line 5 dynamically loads the appropriate network-specific Reach stdlib,
based on the @tech{REACH_CONNECTOR_MODE} environment variable.
If unspecified, Reach's ETH stdlib will be used by default.
All of Reach's network-specific stdlibs adhere to a common interface,
which allows you to write programs which are network-agnostic.}

@item{Lines 7 and 8 initialize new test accounts for Alice and Bob.}

@item{Line 10 has Alice deploy the contact on the consensus network.}

@item{Line 11 has Bob attach to the contract.
The value @jsin{ctcAlice} contains no secret information and could easily be printed out and shared with Bob outside of the consensus network.}

@item{Lines 13 through 22 launch the backends and wait for their completion, we'll look at the details in a moment.}

]

This code will be very similar for all testing programs and demonstrates how straight-forward it is to scaffold a Reach application for testing.

Let's look at initializing and interfacing each participant, starting with Alice.

@reachex[#:mode js
         #:show-lines? #t "overview/index.mjs"
         'only 14 17 "    // ..."]

@itemlist[

@item{Line 14 extracts the backend for Alice.}

@item{Line 14 also passes it the appropriate standard library and contract handle.
It needs these to be able to interface with the consensus network.}

@item{Line 15 provides the @reachin{request} value.}

@item{Line 16 provides the @reachin{info} value.}

]

Let's look at Bob next.

@reachex[#:mode js
         #:show-lines? #t "overview/index.mjs"
         'only 18 21 "    // ..."]

@itemlist[

@item{Line 18 initializes Bob just like Alice.}

@item{Line 19 provides his @reachin{want} function, which produces a log message and always accepts.}

@item{Line 20 provides his @reachin{got} function, which displays the secret on the console as well.}

]

@(hrule)

Reach completely abstracts all the details of the chosen @tech{consensus network} from the programmer, except for those directly impinging on business decisions, like the amounts of currency transacted.
Reach allows programmers to focus on the business logic of their application at every stage, from the core application to the interfacing elements.

@section[#:tag "over-execute"]{Execute}

It's now time to execute this test program and ensure that everything is working correctly.
In this case, we've set up our application simply: there's one Reach file for the application and one JavaScript file for the interface.
This is a common practice, so Reach comes with a simple wrapper script to build and execute such applications.
We just run:

@cmd{reach run}

And then Reach

@itemlist[

@item{compiles @reachexlink["overview/index.rsh" "overview/index.rsh"];}

@item{creates a temporary Node.js package;}

@item{builds a Docker image based on Reach's standard image for the package; and,}

@item{runs the application connected to Reach's standard private Ethereum devnet image.}

]

On typical developer laptops, this entire process takes seconds and can be completely integrated into existing development IDEs, like VSCode, so Reach developers can compile, verify, build, launch, and test their Reach app with a single command.

@(hrule)

Reach completely abstracts all the details of building and maintaining @tech{consensus network} test environments and build scripts from the programmer, so they can focus exclusively on the business logic of their application.
In fact, Reach works for multiple networks, so if we instead run

@cmd{REACH_CONNECTOR_MODE=ALGO reach run}

Then Reach will instead start up a private Algorand devnet image and use the Algorand @tech{connector}.
The developer does not need to change anything about their program, because Reach is entirely agnostic to the @tech{consensus network} choice during deployment.

@section[#:tag "over-react"]{Web app}

@margin-note{You can @link["https://www.youtube.com/watch?v=jHEKIMNvs-o"]{watch a 7-minute video} on YouTube
which demonstrates this section's code in action
and provides a brief explanation of how it works.}

The previous execution uses Node.js to perform a test run at the command line.
However, most Reach developers deploy their DApps via a Web application, as we describe below.

A Web deployment uses the exact same @reachexlink["index.rsh" #:dir "examples/overview-react"] file, but connected to a React-based @reachexlink["index.js" #:dir "examples/overview-react"] file.
(It also uses some simple React @reachexlink["views" #:dir "examples/overview-react"]
 and @reachexlink["index.css" @tt{css} #:dir "examples/overview-react"] to go with it.)
Let's take a look at some snippets from the React @reachexlink["index.js" #:dir "examples/overview-react"] and compare with the Node.js @reachexlink["index.mjs" #:dir "examples/overview"] from before:

@reachex[#:mode js
         #:show-lines? #t "overview-react/index.js"
         'only 7 8 "// ..."]

At the top of the file, we import the Reach-generated backend as @jsin{backend} and the standard library as @jsin{reach}.

@reachex[#:mode js
         #:show-lines? #t "overview-react/index.js"
         'only 27 28 "  // ..."]

We hook into the App @link["https://reactjs.org/docs/react-component.html"]{component}'s @link["https://projects.wojtekmaj.pl/react-lifecycle-methods-diagram/"]{lifecycle event} @jsin{componentDidMount}
in order to fetch the user's account.
@jsin{getDefaultAccount} automatically interacts with browser extensions, like MetaMask, to get the user's
currently-selected account.
Reach is able to deploy contracts and send transactions to the consensus network by prompting the user through the extension's API,
without the Reach programming having to do this in manually.
This is just like how in the Node.js deployment, the Reach programmer does need to decode the details of the underlying consensus network's interaction API.

@reachex[#:mode js
         #:show-lines? #t "overview-react/index.js"
         'only 71 76 "  // ..."]

Our React component has a method called @jsin{deploy} that actually deploys the contract on the network, using the same calls as in the test deployment:
on line 72 we call the @jsin{acc.deploy} function,
and on line 74, we call the @jsin{ctc.getInfo} function;
exactly as we did for the Node.js program.

@reachex[#:mode js
         #:show-lines? #t "overview-react/index.js"
         'only 79 85 "  // ..."]

Similarly, we implement a @jsin{runBackend} method that executes the Reach program as Alice using information gathered from the React UI.

@reachex[#:mode js
         #:show-lines? #t "overview-react/index.js"
         'only 112 121 "  // ..."]

We implement a similar method in the @jsin{Bob} component that runs the backend as Bob,

We specify Alice's and Bob's respective @tech{participant interact interface}s
just as we would in Node.js.
In the React program,
we have the ability to leverage Bob's @reachin{interact} functions as callbacks
that can update the React state
in order to display to, or harvest information from, the React user interface.

You can install the @litchar{@"@"reachsh/stdlib} JavaScript library
into your React project,
or for convenience, instead of setting up a React project,
you can simply use the command

@cmd{reach react}

This command runs your DApp with the React development server in a Docker container which has Reach and React JavaScript dependencies pre-installed, so it starts up much faster than building them yourself.

@section[#:tag "over-next"]{Next steps}

In this overview, we've briefly described the structure and fundamental concepts of a Reach application.
We've shown how to construct a simple program, compile it, connect an interface, test at the command-line, and deploy it using a React Web application.
Since this is only a brief overview of what Reach can do, we left a lot out.
But even so, it is should be clear why Reach is easiest and safest programming language for decentralized application development.

Furthermore, this program has many flaws and should not be used in practice.
For example, it provides no protection to Bob in the event that Alice fails to deliver the information and makes no attempt to ensure that the information is what he wants.
Reach allows you to abstract away the low-level details of your decentralized program and focus on these sorts of bigger picture issues.
In the rest of @seclink["guide"]{the guide}, we discuss design issues like this. For example,

@itemlist[

@item{Effectively using @seclink["guide-assert"]{automatic verification} to check your application;}

@item{Fortifying your application against @seclink["guide-timeout"]{non-participation};}

@item{Building @seclink["guide-abstract"]{interaction abstractions} for related applications.}

]

However, unless you're ready to dive deep now, the next steps for you are to:

@itemlist[

@item{@seclink["install"]{Install Reach};}

@item{Work through the @seclink["tut"]{tutorial};}

@item{Join @(the-community-link).}

]

Thanks for being part of Reach!

