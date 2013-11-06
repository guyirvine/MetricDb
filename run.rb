

class Metric
end

class InMemoryMetric<Metric
    def initialize
        @list = Array.new
    end
    
    def push( value )
        @list.unshift Hash["value", value, "timestamp", Time.now]
        return true
    end
    
    def get(a)
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

class PgMetric<Metric
    def initialize( db, id, name )
        @db = db
        @id = id.to_i
        @name = name
    end

    def push( value )
        @db.execute( "INSERT INTO value_tbl( metric_id, value ) VALUES ( ?, ? )", [@id, value] )
        return true
    end
    
    def get(a)
        return @db.queryForValue( "SELECT value FROM value_tbl WHERE metric_id = ? ORDER BY timestamp DESC LMIIT 1", [@id] )
        rescue FluidDb::NoDataFoundError=>e
        return nil
    end
    
    def range( dateRange )
        return @db.queryForResultset( "SELECT value, timestamp FROM value_tbl WHERE metric_id = ? AND timestamp >= ? AND timestamp <= ? ORDER BY timestamp DESC", [@id, dateRange.begin, dateRange.end ] )
    end
    
    def after( t )
        return @db.queryForResultset( "SELECT value, timestamp FROM value_tbl WHERE metric_id = ? AND timestamp > ? ORDER BY timestamp DESC", [@id, t ] )
    end
    
    def firstAfter( t )
        return @db.queryForArray( "SELECT value, timestamp FROM value_tbl WHERE metric_id = ? AND timestamp > ? ORDER BY timestamp ASC LIMIT 1", [@id, t ] )
        rescue FluidDb::NoDataFoundError=>e
        return nil
    end
    
end

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

    def method_missing( methodName, *args )
        answer = Array.new
        @l.each do |metric|
            answer << metric.send( methodName, args[0] )
        end
        return answer
    end
end

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

class InMemoryServer<Server
    
    def getNewMetric( name )
        return InMemoryMetric.new
    end

end

require "FluidDb/Db"
class FluidPgServer<Server

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
        
        return PgMetric.new( @db, id, name )
    end

    def [](*args)
        l = Array.new
        args.each do |name|
            @h[name] = Metric.new if @h[name].nil?
            l << @h[name]
        end
        return MetricBag.new(l)
    end
end


s = InMemoryServer.new
s["landarea"].push( 1 )
puts s["landarea"].get

t0 = Time.now
s["landarea"].push( 2 )
puts s["landarea"].get(  )

sleep 0.1

t1 = Time.now - 86400
t2 = Time.now
puts s["landarea"].range( t1..t2 )

puts s["landarea"].after( t0 )

s["landarea"].push( 21 )
s["incrop"].push( 22 )
puts s["landarea", "incrop"].get()

puts s["landarea"].firstAfter( t0 )

puts "*** NEW"
puts s["landarea", "incrop"].get()
puts s["landarea"].push( "10" )
puts s["landarea"].get()

