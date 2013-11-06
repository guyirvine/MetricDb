module MetricDb

require "MetricDb/MetricBag"

class Server

    def initialize
        @h = Hash.new
    end
    
    def getNewMetric( name )
        raise "Method, getNewMetric, needs to be implemented"
    end

    def [](*args)
        l = Array.new
        args.each do |name|
            @h[name] = self.getNewMetric( name ) if @h[name].nil?
            l << @h[name]
        end
        return MetricBag.new(l)
    end
end

end
