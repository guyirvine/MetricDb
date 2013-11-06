require "MetricDb"

module MetricDb
    
    def MetricDb.Db( uri )
	uri = URI.parse( uri ) if uri.is_a? String
        
        case uri.scheme
            when "inmemory"
            require "MetricDb/InMemory"
            return MetricDb::InMemory.new( uri )

            else
            abort("Scheme, #{uri.scheme}, not recognised when configuring creating db connection");
        end
        
    end
end
