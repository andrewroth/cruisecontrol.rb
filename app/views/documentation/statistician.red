h1. Showing a progress chart based on CodeStatistics for each project

Used an idea from "O'Reilly Ruby":http://www.oreillynet.com/ruby/blog/2008/03/cruisecontrol_charts.html. Converted it to a bulder_plugin, which first collects the statistics and then creates a svg file after build has finished. CodeStatistics is called once per build, the results are captured, charted to track trends over time. You'll get CodeStatistics if you run <i>rake stats</i>.

p(hint). A symbolic link will be set from 'public/images/charts' to 'shared/charts' where the generated charts will be stored as svg files. Look at 'config/deploy.rb.example' to automate this task in capsistrano when deploying CruiseControl.rb. 

From:
<pre><code>
+----------------------+-------+-------+---------+---------+-----+-------+
| Name                 | Lines |   LOC | Classes | Methods | M/C | LOC/M |
+----------------------+-------+-------+---------+---------+-----+-------+
| Controllers          |   192 |   155 |       4 |      12 |   3 |    10 |
| Helpers              |   270 |   222 |       0 |      35 |   0 |     4 |
| Models               |  1279 |  1036 |      15 |     155 |  10 |     4 |
| Libraries            |  4047 |  2989 |      65 |     326 |   5 |     7 |
| Integration tests    |   305 |   232 |       2 |      29 |  14 |     6 |
| Functional tests     |   542 |   406 |       8 |      48 |   6 |     6 |
| Unit tests           |  4667 |  3706 |      47 |     393 |   8 |     7 |
+----------------------+-------+-------+---------+---------+-----+-------+
| Total                | 11302 |  8746 |     141 |     998 |   7 |     6 |
+----------------------+-------+-------+---------+---------+-----+-------+
  Code LOC: 4402     Test LOC: 4344     Code to Test Ratio: 1:1.0
</code></pre>

you'll get a chart like this:

!/images/documentation/statistician.png!


You can configure the chart with:
<pre><code>
project.statistician.test_filter = ["Model specs",
                                    "View specs",
                                    "Controller specs",
                                    "Helper specs",
                                    "Library specs",
                                    "Unit tests", 
                                    "Functional tests",
                                    "Integration tests"]
    
project.statistician.code_filter = ["Libraries", 
                                    "Helpers",
                                    "Controllers",
                                    "Models"]
</code></pre>

p(hint). If you think of more trends to display, the architecture will make them easy to add. Starting by counting the lines of tests & code, and calculating their ratio.
These signals occupy different orders of magnitude, so a logarithmic scale reveals their common slopes. We use Gnuplot to make such charts easy; this paltry output is only the beginning of Gnuplot’s abilities.

