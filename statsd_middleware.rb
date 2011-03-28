class StatsdMiddleware
  def initialize(app, statsd)
    @app = app
    @statsd = statsd
  end
  
  def call(env)
    dup._call(env)
  end
  
  def _call(env)
    @host = host(env)
    @start = Time.now
    @status, @headers, @response = @app.call(env)
    @end = Time.now
    [@status, @headers, self]
  end
  
  def each(&block)
    @statsd.increment("#{@host}.total.pages_served")
    @statsd.increment("#{@host}.#{served_by(@headers)}.pages_served")
    @response.each(&block)
  end
  
  def served_by(headers)
    headers['X-Served-By'].gsub('.', '_')
  end

  def host(env)
    env['SERVER_NAME'].gsub('.', '_')
  end

  # =============
  # = DEBUGGING =
  # =============
  
  def log_file
    File.dirname(__FILE__)+"/../../log/#{Rails.env}_statsd.log"
  end

  def logit(string)
    `echo "#{string}" >> #{log_file}`
  end
  
end
