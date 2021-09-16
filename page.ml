open Tyxml.Html

let header t =
  head
    (title (txt t))
    ([meta ~a:[a_charset "UTF-8"] ();
      style [ txt
    {___|body {
           font-family: monospace;
           color: #333;
           margin: 2% 0 10% 15%;
           width: 45%;
         }
         a, a:visited {
           color: #333;
           text-decoration: none;
           font-weight: bold;
         }|___} ]
        ])

let content =
  Omd.to_html (Omd.of_string
{___|# 10th MirageOS hack retreat

We invite you to participate in the ninth [MirageOS](https://mirage.io)
hack retreat!
The goal is to sync various MirageOS subprojects, start new ones,
and fix bugs.

* *When?* November 8th (arrival) - November 14th (departure) 2021
* *Where?* Mirleft, Marocco
* *Travelling information* To enter Morocco, you need a vaccination certificate and a negative PCR test. Next airport is Agadir.
* *How much?* 450 EUR<sup>&#9733;</sup>, accommodation (single rooms) and food (full board) included. No refunds possible.
* *How do I register?* Register by sending a mail to <retreat2021@nqsb.io> **by September 20th, 2021** including:
   * How you became interested in MirageOS;
   * Previous experience with MirageOS and OCaml (no upfront experience required) ;
   * Project(s) you're interested to work on; and
   * Dietary restrictions
* *Who should participate?* Everybody interested in advancing MirageOS.
* *How big?* We have only limited space (25 people).  Selection will be done by various diversity criteria.
* *How should I behave while there?* Be kind and empathetic to others; do not harrass or threaten anyone. If you make others unsafe, you may be asked to leave.

<sup>&#9733;</sup>: If you cannot afford this, please contact us directly (at <retreat2020@nqsb.io>).

<br/>

More information
* Once you've signed up, you will subscribed to the participants mailing list.
* You can work on anything but if you need inspiration, browse the [projects](http://canopy.mirage.io/tags/help%20needed) which need help.
* Travel to Agadir, from there take the bus or a taxi to Mirleft.

Previous retreats:
* 9th March 13th - 19th 2020 in Marrakesh
* 8th September 23rd - 29th 2019 in Marrakesh, reports: [curtisanne (OpenLab Augsburg), in german](https://openlab-augsburg.de/2019/10/lablinked-marrakesh-mirageos-retreat/) [comparing type classes with modules by mark karpov](https://markkarpov.com/post/what-does-a-humped-critter-have-to-teach-us.html)
* 7th March 6th - 13th 2019 in Marrakesh, reports: [report](https://mirage.io/blog/2019-spring-retreat-roundup) [lynxis](https://lunarius.fe80.eu/blog/mirageos-2019.html) [gabriel](http://gallium.inria.fr/blog/marrakesh-retreat-03-2019/) [tarides](https://tarides.com/blog/2019-05-06-7th-mirageos-hack-retreat.html)
* 6th October 3rd - 10th 2018 in Marrakesh
* 5th March 7th - 18th 2018 in Marrakesh, reports: [linse](https://linse.me/2018/04/20/Visiting-the-camels.html), [peter](https://mirage.io/wiki/arm64)
* 4th November 29th - December 6th 2017 in Marrakesh, reports: [mirage](https://mirage.io/blog/2017-winter-hackathon-roundup)
* 3rd March 1st - 8th 2017 in Marrakesh, reports: [mirage](https://mirage.io/blog/2017-march-hackathon-roundup), [reynir](http://reyn.ir/posts/2017-03-20-11-27-Marrakech%202017.html), [olle](http://ollehost.dk/blog/2017/03/17/travel-report-mirageos-hack-retreat-in-marrakesh-2017/)
* 2nd 13th July 2016 at Darwin College in Cambridge, [report](https://mirage.io/blog/2016-summer-hackathon-roundup)
* 1st March 11th - 16th 2016 in Marrakesh, [report](https://mirage.io/blog/2016-spring-hackathon)
|___})

let rendered =
  let buf = Buffer.create 500 in
  let fmt = Format.formatter_of_buffer buf in
  pp () fmt @@
  html
    (header "MirageOS hack retreats")
    (body [ Unsafe.data content ]) ;
  Cstruct.of_string (Buffer.contents buf)
