require 'test/unit'

require './lib/MetricDb/InMemory'


class InMemoryTest < Test::Unit::TestCase

    def setup
        @s = MetricDb::InMemory_Server.new
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
        t2 = Time.now
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
