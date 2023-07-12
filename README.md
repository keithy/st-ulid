# st-ulid
#### BaseEncoder

A universal encoder/decoder supporting a variety of character sets with arbitrary bit widths

crockford (32) is used for ulid's
### ulid implementation in smalltalk

A Variant on the standard Ulid, that is better (by some definiton of better) and backwards compatible.

The standard Ulid is 10 bytes time and 16 bytes randomness with a bit of non-randomness and
unneccessary complexity thrown in as a counter, that is likely to be needed to compensate for
the coarse clock.

This variant Ulid is 
	
	`<10 chars milliseconds time>` `<2 chars microseconds>` `<14 chars randomness>`.

	This slightly quirky pattern retains essential backwards compatability with the canonical form.

Loosing 10 bits of randomness is more than made up for by the 1000x finer clock, chances of collisions decrease.

Pharo is able to generate and collect > 380000/ulids per second (on a 2013 Macbook)  Parsing rate is 100k/sec

At this rate the micro-second time resolution of this implementation is sufficient to provide a guarentee of lexical sorting that 
betters the original's lack of sincerity.

If it doesnt, then the solution is to simply slow down or do something else!! 
By default this implementation resists creating 2 timestamps within a single microsecond, 
and thus guarentees both a monotonic clock,  and lexical sorting, without any of the usual compromises.

If you needed faster, then likely you wouldnt be using smalltalk. 
(Some python ulid implementations boast 5000/sec)

380000/sec raw instanciations collecting (without printing/encoding).
150000/sec with encodings
 
 refs:
 https://wvlet.org/airframe/docs/airframe-ulid
airframe-ulid can produce 5 million ULIDs / sec. 
As of April 2021, airframe-ulid is the fastest ULID generator in Scala:


https://github.com/Sofya2003/ULID-with-sequence
## Installation```Metacello new	repository: 'github://keithy/st-ulid:main/src';	baseline: 'Encoder';	load```