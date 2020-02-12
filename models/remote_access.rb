require "json"
require "open-uri"

# Sets up and maintains a remote access tunnel.
class RemoteAccess < Module
  attr_accessor :config, :enabled

  def initialize(config)
    self.config = config
    self.enabled = true
  end

  def start
    write_log("Starting", append: false)
    write_status(:starting)
    pid = spawn("ngrok", "tcp", (config["ssh_port"] || 22).to_s, "-log=stdout",
      %i[out err] => [log_path, "a"])
    write_status(:starting, "pid" => pid)
  rescue StandardError => e
    write_log(e)
    write_status(:failed)
    raise e # Re-raise error so full backtrace gets logged to server log.
  end

  def close
    if status["pid"]
      Process.kill("HUP", status["pid"])
      write_log("Remote access closed.")
    else
      write_log("Error closing remote access: PID is not stored.")
    end
  rescue Errno::EPERM
    write_log("Error closing remote access: No permission to query #{signal['pid']}.")
  rescue Errno::ESRCH
    write_log("Error closing remote access: PID #{signal['pid']} is not running.")
  end

  def status
    return @status if @status
    @status = super
    begin
      response = JSON.parse(open("http://localhost:4040/api/tunnels").string)
      if response.is_a?(Hash) && (tunnels = response["tunnels"]) && tunnels.any?
        @status["status"] = "running" # Overwrites 'starting' status in file.
        @status["url"] = tunnels[0]["public_url"]
      end
    rescue Errno::ECONNREFUSED
      @status["status"] = "closed" unless @status["status"] == "failed"
    end
    @status
  end

  def url
    status["url"]
  end

  protected

  def module_name
    "remote"
  end
end
