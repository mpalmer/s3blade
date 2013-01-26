# S3Blade

S3Blade is a program to provide an
[ATA-over-Ethernet](http://en.wikipedia.org/wiki/ATA_over_Ethernet) block
device whose storage backend is an object storage service such as Amazon S3.


## WHY?!?

There is no reason why anyone would ever want to use this in production.  It
is slow, relatively unreliable, and grossly inefficient.  In reality, this
program is an example of why aging hackers should not be encouraged to drink
lots of redbull, stay up late, and "do something interesting" to a deadline. 
Built at [Anchor's first
hackfest](http://www.anchor.com.au/blog/2013/01/the-dust-settles-on-anchors-first-hackfest/),
it came into being solely as a late night attempt to produce *something*
that hadn't been done before.  The rationale was that since everything
useful had already been done by someone else, I'd have to delve deep into
the realm of "stupid stuff nobody would ever think to try".  I might have
gone too deep.

Now, the only reason I keep hacking on this is because I like to see how far
I can take a stupid idea before I get bored and give up (or I destroy the
universe).  You'll know I've officially lost the plot when I reimplement the
entire thing in C, "for speed".


## Want to help?

If you have some misguided desire to help improve this program, please
submit a pull request with some useful-looking code.  Don't submit bug
reports, because while using this thing at *all* is crazy, using it when you
don't know enough about what you're doing to be able to fix it yourself
isn't something I'm willing to encourage.


## But... I like AoE!

Great.  So do I.  Go use one of the many *useful* implementations of an AoE
target, like vblade, ggaoed, or qaoed.  If you use *this* AoE target, you're
insane.
