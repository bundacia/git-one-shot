require 'spec_helper'

require 'tmpdir'
require 'git'
require './git_one_shot'

describe GitOneShot do
  subject { described_class.new(git_url) }

  let(:git_url      ) { "file://#{tmp_dir}"        }
  let(:tmp_dir      ) { Dir.mktmpdir               }
  let(:file_name    ) { 'secret.txt'               }
  let(:master_file_content ) { 'Soylent Green is people!' }
  let(:branch1_file_content) { 'Soylent Green is puppies!' }

  let(:repo) { Git.init tmp_dir }

  before(:each) do
    repo.config('receive.denyCurrentBranch', 'ignore')

    Dir.chdir tmp_dir do
      File.write(file_name, master_file_content)
      repo.add(:all => true)
      repo.commit('initial commit')

      repo.branch('branch1').checkout
      File.write(file_name, branch1_file_content)
      repo.add(:all => true)
      repo.commit('branch1 commit')
    end
  end
  after(:each) { FileUtils.rmtree tmp_dir }
  after(:each) { subject.close }

  describe '#read' do
    it 'reads from master by default' do 
      expect( subject.read file_name ).to eq master_file_content
    end
    it 'accepts a branch' do 
      expect( subject.read file_name, branch: :branch1 ).to eq branch1_file_content
    end
  end
  
  describe '#write' do
    it 'writes to master by default' do 
      subject.write file_name, 'new content'
      expect( subject.read file_name ).to eq 'new content'
    end
    it 'accepts a branch' do 
      subject.write file_name, 'new content', branch: :branch1
      expect( subject.read file_name, branch: :branch1 ).to eq 'new content'
    end
  end
  
  describe '#close' do
    it 'removed the local repo' do
      expect( File.exists? subject.send(:repo_dir) ).to be true
      subject.close
      expect( File.exists? subject.send(:repo_dir) ).to be false
    end
  end
  
end
