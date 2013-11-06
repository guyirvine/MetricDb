module MetricDb

require "MetricDb/Metric"

class FluidDb_Metric<Metric
    def initialize( db, id, name )
        @db = db
        @id = id.to_i
        @name = name
    end

    def massageArray( input )
        return Hash["value", input["value"].to_i, "timestamp", Time.parse( input["timestamp"] )]
    end
    def massage( input )
        return massageArray( input ) if input.is_a? Hash
        
        l = Array.new
        input.each do |r|
            l << massageArray( r )
        end
        return l
    end


    def q( sql, params )
        return massage( @db.queryForResultset(sql, params ))
    end

    def push( value )
        @db.execute( "INSERT INTO value_tbl( metric_id, value ) VALUES ( ?, ? )", [@id, value] )
        return true
    end

    def get()
        r = @db.queryForArray( "SELECT value, timestamp FROM value_tbl WHERE metric_id = ? ORDER BY timestamp DESC LIMIT 1", [@id] )
        return massage(r)
        rescue FluidDb::NoDataFoundError=>e
        return nil
    end

    def range( dateRange )
        return q( "SELECT value, timestamp FROM value_tbl WHERE metric_id = ? AND timestamp >= ? AND timestamp <= ? ORDER BY timestamp DESC", [@id, dateRange.begin, dateRange.end ] )
    end

    def after( t )
        return q( "SELECT value, timestamp FROM value_tbl WHERE metric_id = ? AND timestamp > ? ORDER BY timestamp DESC", [@id, t ] )
    end

    def firstAfter( t )
        return massage(@db.queryForArray( "SELECT value, timestamp FROM value_tbl WHERE metric_id = ? AND timestamp > ? ORDER BY timestamp ASC LIMIT 1", [@id, t ] ))
        rescue FluidDb::NoDataFoundError=>e
        return nil
    end
    
end

end
