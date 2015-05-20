require 'json'
require 'net/http'
require 'serverspec'

# Required by serverspec
set :backend, :exec

describe user('dynatrace') do
  it { should exist }
  it { should belong_to_group 'dynatrace' }
end

describe file('/opt/dynatrace') do
  it { should be_directory }
  it { should be_symlink }
  it { should be_owned_by 'dynatrace' }
  it { should be_grouped_into 'dynatrace' }
end

describe file('/opt/dynatrace/agent') do
  it { should be_directory }
  it { should be_owned_by 'dynatrace' }
  it { should be_grouped_into 'dynatrace' }
end

describe file ('/opt/dynatrace/agent/conf/dtwsagent.ini') do
  its(:content) { should match /Name .+/ }
  its(:content) { should match /Server .+/ }
end

describe service('dynaTraceCollector') do
  it { should be_enabled }
  it { should be_running }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
      it { should be_enabled.with_level(3) }
      it { should be_enabled.with_level(4) }
      it { should be_enabled.with_level(5) }
  end
end

describe service('dynaTraceServer') do
  it { should be_enabled }
  it { should be_running }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
      it { should be_enabled.with_level(3) }
      it { should be_enabled.with_level(4) }
      it { should be_enabled.with_level(5) }
  end
end

describe service('dynaTraceWebServerAgent') do
  it { should be_enabled }
  it { should be_running }

  if os[:family] == 'debian' || os[:family] == 'ubuntu'
      it { should be_enabled.with_level(3) }
      it { should be_enabled.with_level(4) }
      it { should be_enabled.with_level(5) }
  end
end

describe port(2021) do
  it { should be_listening }
end

describe port(6698) do
  it { should be_listening }
end

describe port(6699) do
  it { should be_listening }
end

describe port(8020) do
  it { should be_listening }
end

describe port(8021) do
  it { should be_listening }
end

describe port(9998) do
  it { should be_listening }
end

describe 'Dynatrace Server Performance Warehouse Configuration' do
  it 'server should should respond with correct configuration' do
    uri = URI('http://localhost:8020/rest/management/pwhconnection/config')
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri, {'Accept' => 'application/json'})
    request.basic_auth 'admin', 'admin'
    response = http.request(request)

    expect(response.code).to eq('200')

    data = JSON.parse(response.body)
    expect(data['pwhconnectionconfiguration']['host']).to eq('localhost')
    expect(data['pwhconnectionconfiguration']['port']).to eq('5432')
    expect(data['pwhconnectionconfiguration']['dbms']).to eq('postgresql')
    expect(data['pwhconnectionconfiguration']['dbname']).to eq('dynatrace-pwh')
    expect(data['pwhconnectionconfiguration']['user']).to eq('dynatrace')
    expect(data['pwhconnectionconfiguration']['password']).to eq('*********')
    expect(data['pwhconnectionconfiguration']['usessl']).to eq(false)
  end
end