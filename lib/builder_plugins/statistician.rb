#  h1. Showing a progress chart based on CodeStatistics for each project
#  
#  Used an idea from "O'Reilly Ruby":http://www.oreillynet.com/ruby/blog/2008/03/cruisecontrol_charts.html. Converted it to a bulder_plugin, which first collects the statistics and then creates a svg file after build has finished. CodeStatistics is called once per build, the results are captured, charted to track trends over time. You'll get CodeStatistics if you run <i>rake stats</i>.
#  
#  p(hint). A symbolic link will be set from 'public/images/charts' to 'shared/charts' where the generated charts will be stored as svg files. Look at 'config/deploy.rb.example' to automate this task in capsistrano when deploying CruiseControl.rb. 
#  
#  You'll get a chart like this:
#  
#  !/images/documentation/statistician.png!
#  
#  from: 
#  
#  +----------------------+-------+-------+---------+---------+-----+-------+
#  | Name                 | Lines |   LOC | Classes | Methods | M/C | LOC/M |
#  +----------------------+-------+-------+---------+---------+-----+-------+
#  | Controllers          |   192 |   155 |       4 |      12 |   3 |    10 |
#  | Helpers              |   270 |   222 |       0 |      35 |   0 |     4 |
#  | Models               |  1279 |  1036 |      15 |     155 |  10 |     4 |
#  | Libraries            |  4047 |  2989 |      65 |     326 |   5 |     7 |
#  | Integration tests    |   305 |   232 |       2 |      29 |  14 |     6 |
#  | Functional tests     |   542 |   406 |       8 |      48 |   6 |     6 |
#  | Unit tests           |  4667 |  3706 |      47 |     393 |   8 |     7 |
#  +----------------------+-------+-------+---------+---------+-----+-------+
#  | Total                | 11302 |  8746 |     141 |     998 |   7 |     6 |
#  +----------------------+-------+-------+---------+---------+-----+-------+
#    Code LOC: 4402     Test LOC: 4344     Code to Test Ratio: 1:1.0
#  
#  
#  You can configure the chart with:
#  <pre><code>
#  project.statistician.test_filter = ["Model specs",
#                                      "View specs",
#                                      "Controller specs",
#                                      "Helper specs",
#                                      "Library specs",
#                                      "Unit tests", 
#                                      "Functional tests",
#                                      "Integration tests"]
#      
#  project.statistician.code_filter = ["Libraries", 
#                                      "Helpers",
#                                      "Controllers",
#                                      "Models"]
#  </code></pre>
#  
#  p(hint). If you think of more trends to display, the architecture will make them easy to add. Starting by counting the lines of tests & code, and calculating their ratio.
#  These signals occupy different orders of magnitude, so a logarithmic scale reveals their common slopes. We use Gnuplot to make such charts easy; this paltry output is only the beginning of Gnuplot’s abilities.

require 'fileutils'
require 'code_statistics'

class Statistician
  attr_accessor :test_filter, :code_filter
  attr_writer :from

  def initialize(project=nil)
    @project = project
    @test_filter = []
    @code_filter = []
  end

  def build_finished(build)
    run_in_here = @project.path + '/work'
    FileUtils.cd(run_in_here){  append_stats(@project); plot_stats(@project)  }
  end
  
  def append_stats(project)
    yaml = collect_stats
    plop = project.path + '/statistics.yaml'
    File.open(plop, 'a+'){|f| f.write(yaml) }
  end
  
  def plot_stats(project)    
    return if @test_filter.empty? or @code_filter.empty?
    plot_svg(project, 'Test:Code' => lambda{ |stats|
                                             test = fetch_codelines(stats, @test_filter)
                                             code = fetch_codelines(stats, @code_filter)
                                             return test.to_f / code.to_f
                                           })
  end
end

STATS_FOLDERS = [
  %w(Controllers        app/controllers),
  %w(Helpers            app/helpers), 
  %w(Models             app/models),
  %w(Libraries          lib/),
  %w(APIs               app/apis),
  %w(Components         components),
  %w(Integration\ tests test/integration),
  %w(Functional\ tests  test/functional),
  %w(Unit\ tests        test/unit),
  %w(Model\ specs       spec/models),
  %w(View\ specs        spec/views),
  %w(Controller\ specs  spec/controllers),
  %w(Helper\ specs      spec/helpers),
  %w(Library\ specs     spec/lib) 
].freeze

class CodeStatistics;  attr_reader :statistics;  end

def collect_stats
  #  code callously ripped from statistics.rake !
  folders = STATS_FOLDERS.select{|name, dir| File.directory?(dir) }
  cs      = CodeStatistics.new(*folders)
  statz   = cs.statistics
  tyme    = Time.now.to_i
  yaml    = { "build_#{ tyme }" => statz }.to_yaml
  return yaml.sub(/^---/, '')  #  abrogate that pesky document marker!
end
    
def get_stats(project)
  statistics = File.read(project.path + '/statistics.yaml')
  statistics = YAML::load(statistics)
  statistics = statistics.map{|k,v| [k.sub('build_', '').to_i, v] }
  return statistics.sort
end
 
def plot_svg(project, signals = {})
  signals = { 'Code' => @code_filter, 'Test' => @test_filter }.merge(signals)
  name = project.name
  path = "#{RAILS_ROOT}/public/images/charts"
  Dir.mkdir(path) unless File.directory?(path)
  output_file = "#{path}/#{name}.svg"
  #  drastically prevent false positives in manual tests
  File.unlink(output_file) if File.exist?(output_file)

  Gnuplot.open do |gp|      
    Gnuplot::Plot.new( gp ) do |plot|
      #  decorate the chart
      plot.xdata 'time'
      plot.key 'outside title "   Code Lines   "'
      plot.grid 'ytics'
      plot.timefmt timefmt.inspect # for quote marks
      plot.term 'svg'
      plot.output output_file
      plot.title name
      plot.logscale 'y'
      stats = get_stats(project)
      
      #  set the time range
      timestamps = stats.map(&:first)
      statistics = stats.map(&:last)
      mini = timestamps.first - 60
      maxi = timestamps.last  + 60
      plot.xrange "['#{ ftime(mini) }':'#{ ftime(maxi) }']"
      times = timestamps.map{|v| ftime(v.to_i)  }
      maxi = 0

      #  collect each signal and add its plot line
      plot.data = signals.keys.sort.map do |legend|
        fields = signals[legend]
        
        values = statistics.map do |stat|
          if fields.respond_to? :call
            fields.call(stat)
          else
            fetch_codelines(stat, fields)
          end 
        end
        maxi = [maxi, *values].max
        
        Gnuplot::DataSet.new( [times, values] ) do |ds|
          ds.with = "linespoints"
          ds.title = legend
          ds.using = '1:2'
          ds.linewidth = 4
        end
      end

      #  set the chart height
      next_order_of_magnitude = 10 ** (Math.log10(maxi) + 1.1).to_i
      plot.set 'yrange', "[0.01:#{next_order_of_magnitude}]"
    end
  end  #  this 'end' writes the output SVG
  
  #  Gnuplot can't beautify the SVG enough, so we tweak these things
  svg  = File.read(output_file)
  doc  = REXML::Document.new(svg)
  node = REXML::XPath.first(doc, "//text[ '#{name}' = . ]")
  return unless node
  node.attributes['style'] = 'fill: #507ec0; font-family:Arial,sans; font-size: 0.8cm;'
  node = REXML::XPath.first(doc, '/svg')
  node.attributes['height'] = nil
  node.attributes['width'] = nil
  #  and finally write the SVG again
  File.open(output_file, 'w'){|f| doc.write(f) }
end  

def timefmt;  '%Y/%d/%m-%H:%M';  end

def fetch_codelines(stat, fields)
  return stat.values_at(*fields).map{|values| values['codelines'] }.sum 
end

def ftime(timestamp)
  Time.at(timestamp).strftime(timefmt)
end  

Project.plugin :statistician
