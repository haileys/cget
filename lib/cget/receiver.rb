require "cget/protocol_error"
require "thread"

module CGet
  class Receiver
    attr_reader :file, :connections, :threads, :queue

    def initialize(file, connections)
      @file = file
      @connections = connections
      @threads = []
      @queue = Queue.new
    end

    def run
      spawn_threads

      while threads.any?
        message = queue.pop
        handle_message(message)
      end
    end

    def spawn_threads
      @threads = connections.map { |connection|
        Thread.start do
          run_connection(connection)
        end
      }
    end

    def handle_message(message)
      case message[:type]
      when :write
        buffer = message[:buffer]
        offset = buffer[0, 8].unpack("Q>").first
        raise ProtocolError, "bad offset: #{offset}" if offset > file.size
        file.seek(offset)
        file.write(buffer[8, 4096])
      when :join
        message[:thread].join
        threads.delete(message[:thread])
      end
    end

    def run_connection(connection)
      while buff = connection.read(4096 + 8)
        queue << { type: :write, buffer: buff }
      end

      queue << { type: :join, thread: Thread.current }
    end
  end
end
