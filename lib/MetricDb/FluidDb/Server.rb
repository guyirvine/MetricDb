module MetricDb

require "MetricDb/Server"

class FluidDb_Server<Server

    def initialize( uri )
        super()
        @db = FluidDb.Db( uri )
    end

    def getNewMetric( name )
        id = nil
        begin
            id = @db.queryForValue( "SELECT id FROM metric_tbl WHERE name = ?", [name] )
        
        rescue FluidDb::NoDataFoundError=>e
    
            id = @db.queryForValue( "SELECT NEXTVAL( 'metric_seq' )", [] )
            @db.execute( "INSERT INTO metric_tbl( id, name ) VALUES ( ?, ? )", [id.to_i, name])
        end

        return FluidDb_Metric.new( @db, id, name )
    end

end

end
