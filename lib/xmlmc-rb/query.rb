require_relative 'record'
module Xmlmc
  class Query
    attr_reader :rs
    attr_reader :iface
    attr_accessor :current_row

    def initialize rs, iface
      @rs = rs
      @iface = iface
      @current_row = nil
    end

    def each &code
      @current_row = 0
      @rs[:data].each do |i|
        code.call Record.new i, @iface, @current_row
        @current_row += 1
      end
      @current_row = nil
    end

    def affected_records
      @rs[:rowsEffected]
    end

    def field field, row = 0
      f = @iface.prep_for_hash field, true
      # if @current_row
      #   row = @current_row
      # end
      @rs[:data][row][f]
    end
  end
end