module CGet
  class SpeedCalculator
    Sample = Struct.new(:bytes, :time)

    attr_reader :samples, :max_samples, :min_interval

    def initialize(max_samples = 10, min_interval = 0.5)
      @samples = []
      @max_samples = max_samples
      @min_interval = min_interval.to_f
    end

    def speed
      if samples.size >= 2
        bytes_delta / time_delta
      else
        0
      end
    end

    def formatted_speed
      speed = self.speed

      if speed < 1024
        "%d B/s" % speed
      elsif speed < 1024 * 1024
        "%d KiB/s" % (speed / 1024)
      elsif speed < 10 * 1024 * 1024
        "%.1f MiB/s" % (speed / 1024 / 1024)
      else
        "%d MiB/s" % (speed / 1024 / 1024)
      end
    end

    def bytes_delta
      samples.last.bytes - samples.first.bytes
    end

    def time_delta
      samples.last.time - samples.first.time
    end

    def sample(total_bytes)
      now = Time.now.to_f
      if samples.empty? || now > samples.last.time + min_interval
        @samples = [*samples, Sample.new(total_bytes, now)].last(max_samples)
      end
    end
  end
end
