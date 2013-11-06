require 'test/unit'

require './lib/MetricDb/FluidDb'

class Test_FluidDb_Server<MetricDb::FluidDb_Server

    def initialize(uri)
        super(uri)
        
        @db.execute( "DELETE FROM value_tbl", [] )
        @db.execute( "DELETE FROM metric_tbl", [] )
    end
    
end

class FluidDbTest < Test::Unit::TestCase

    def setup
        @s = Test_FluidDb_Server.new( "pgsql://girvine:coffee11@localhost/metricdb" )
        
    end

    def test_push
        @s["landarea"].push( 1 )
    end

    def test_push_get
        @s["landarea"].push( 1 )
        assert_equal 1, @s["landarea"].get()
    end

    def test_push_push_get
        @s["landarea"].push( 1 )
        @s["landarea"].push( 2 )
        assert_equal 2, @s["landarea"].get()
    end
    
    def test_push_push_range
        @s["landarea"].push( 1 )
        t0 = Time.now
        @s["landarea"].push( 2 )

        t1 = Time.now - 86400
        t2 = Time.now + 10
        assert_equal 2, @s["landarea"].range( t1..t2 ).length
    end
    
    def test_push_push_after
        @s["landarea"].push( 1 )
        t0 = Time.now
        @s["landarea"].push( 2 )
        
        assert_equal 1, @s["landarea"].after( t0 ).length
    end
    
    def test_push_push_multiple
        @s["landarea"].push( 1 )
        @s["landarea"].push( 2 )
        @s["incrop"].push( 22 )
        @s["landarea"].push( 21 )

        l = @s["landarea", "incrop"].get()

        assert_equal 2, l.length
        assert_equal 21, l[0]
        assert_equal 22, l[1]
        
    end
    
    def test_push_push_firstAfter
        @s["landarea"].push( 1 )
        t0 = Time.now
        @s["landarea"].push( 2 )
        @s["landarea"].push( 21 )

        r = @s["landarea"].firstAfter( t0 )
        assert_equal 2, r["value"]
    end
    
    
end
