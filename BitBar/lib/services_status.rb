require 'json'

major = RUBY_VERSION[/^(\d)\./, 1] \
  or raise "failed to fetch Ruby major version number"
mini = 2; major.to_i >= mini \
  or raise "required Ruby version: >= %d.0.0" % [mini]

# For mg that requires node
ENV["PATH"] = "#{ENV.fetch "HOME"}/.ndenv/shims:#{ENV["PATH"]}"

module ServicesStatus
  def self.print(names)
    json = Dir.chdir ENV.fetch("HOME") + "/code/services" do
      `./node_modules/.bin/mg status --json`
    end
    info = JSON.parse(json)
    services = info.
      select { |name,| names.include? name }.
      map { |name, status| Service.new(name, status) }
    alive, stopped = services.sort_by(&:name).partition &:alive?
    # See https://goo.gl/a0LcnZ
    puts(if services.empty?
      "\u{25B7}"
    elsif alive.size == services.size
      "\u{25B6}"
    else
      "%s/%d" % [ansi("31", stopped.size), services.size]
    end)
    puts "---"
    puts "%d services" % services.size
    if !stopped.empty?
      puts "---"
      stopped.each do |s|
        puts [s.name, ansi("31", s.state)] * " : "
      end
    end
    if !alive.empty?
      puts "---"
      alive.each do |s|
        puts [s.name, s.state, s.pid, format_duration(s.uptime)] * " : "
      end
    end
  end

  def self.ansi(code, str)
    "\033[#{code}m#{str}\033[0m"
  end

  def self.format_duration(i)
    i /= 1000
    if i < 60
      "%ds" % i
    else
      units =[
        ['d', i / 86400],
        ['h', i / 3600 % 24],
        ['m', i / 60 % 60],
      ]
      units.
        drop_while { |*,n| n == 0 }.
        map { |u,n| "%d%s" % [n,u] }.
        join(" ")
    end
  end

  class Service
    def initialize(name, status)
      @name, @status = name, status
    end

    attr_reader :name

    def state;  @status.fetch("state") end
    def pid;    @status.fetch("pid") end
    def uptime; @status.fetch("uptime") end

    def alive?
      state == "alive"
    end
  end
end
