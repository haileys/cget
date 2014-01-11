require "cget/speed_calculator"

module CGet
  class UI
    attr_reader :speed_calculator, :total_read, :total_size

    def initialize(total_size)
      @total_size = total_size
      @total_read = 0
      @speed_calculator = CGet::SpeedCalculator.new
      @last_status_line = ""

      speed_calculator.sample(0)
    end

    def notify_bytes_read(bytes)
      @total_read += bytes
      speed_calculator.sample(total_read)
    end

    def render(io)
      status_line = "#{total_read / 1024 / 1024} / #{total_size / 1024 / 1024} MiB (#{speed_calculator.formatted_speed})"
      status_line = status_line.ljust(@last_status_line.size, " ")
      @last_status_line = status_line
      io.print("  #{status_line}\r")
    end
  end
end
