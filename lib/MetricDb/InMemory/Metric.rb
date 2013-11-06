module MetricDb

require "MetricDb/Metric"

class InMemory_Metric<Metric
    def initialize
        @list = Array.new
    end
    
    def push( value )
        @list.unshift Hash["value", value, "timestamp", Time.now]
        return true
    end

    def get()
        return @list[0]
    end
    
    def range( dateRange )
        l = Array.new
        @list.each do |r|
            l << r if dateRange.cover?(r["timestamp"])
        end
        
        return l
    end
    
    def after( t )
        l = Array.new
        @list.each do |r|
            l << r if r["timestamp"] > t
        end
        
        return l
    end
    
    def firstAfter( t )
        last = nil
        @list.each do |r|
            last = r if r["timestamp"] > t
            break if r["timestamp"] <= t
        end
        
        return last
    end
    
end

end
