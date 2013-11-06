module MetricDb

class MetricBag

    def initialize( list )
        @l = list
    end
    
    def push( value )
        answer = Array.new
        @l.each do |metric|
            answer << metric.push(value)
        end
        return answer
    end
    
    def get()
        answer = Array.new
        @l.each do |metric|
            answer << metric.get()["value"]
        end

        return answer[0] if answer.length == 1
        return answer
    end

    def method_missing( methodName, *args )
        answer = Array.new
        @l.each do |metric|
            answer << metric.send( methodName, args[0] )
        end

        return answer[0] if answer.length == 1
        
        return answer
    end
end

end
