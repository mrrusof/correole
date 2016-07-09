require File.expand_path '../../test_helper.rb', __FILE__

describe 'Command `correole`' do

  let(:port) { 5987 }
  let(:timeout) { 10 }
  let(:root) { File.expand_path '../../../', __FILE__ }
  let(:cmd) { "PORT=#{port} ruby -I #{root}/lib -I #{root}/config #{root}/bin/correole" }

  it "runs API" do
    spawn(cmd, [ :err, :out ] => '/dev/null')
    stop = Time.now.to_i + 10
    while ! system("lsof -i TCP:#{port}", [ :err, :out ] => '/dev/null') && Time.now.to_i < stop
      print '#'
      sleep 0.25
    end
    assert system("lsof -i TCP:#{port}", [ :err, :out ] => '/dev/null'), "Correole did not start within #{timeout} seconds."
    pid = %x( lsof -i TCP:#{port} -F p )[1..-1]
    Process.kill(9, pid.to_i)
  end

end
