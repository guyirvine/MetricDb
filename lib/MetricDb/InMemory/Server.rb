module MetricDb

require "MetricDb/Server"

class InMemory_Server<Server
    
    def getNewMetric( name )
        return InMemory_Metric.new
    end

end

end
