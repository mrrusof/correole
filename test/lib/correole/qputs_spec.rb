require File.expand_path '../../../test_helper.rb', __FILE__

describe 'qputs' do

  before do
    @curr_quiet = Configuration.quiet
    @curr_stdout = $stdout
    $stdout = StringIO.new
  end

  after do
    $stdout = @curr_stdout
    Configuration.quiet = @curr_quiet
  end

  it 'does print when not in quiet mode' do
    Configuration.quiet = false
    qputs 'test'
    _($stdout.string).must_equal "test\n", 'does not print'
  end

  it 'does not print when in quiet mode' do
    Configuration.quiet = true
    qputs 'test'
    _($stdout.string).must_equal '', 'does print'
  end

end
