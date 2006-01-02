class Person
    attr_reader :first, :last
    attr_writer :first, :last
    def initialize(first, last)
        @first = first
        @last = last
    end
    
    def to_s
        "#@first, #@last"
    end
    
end
