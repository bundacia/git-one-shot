class GitOneShot

  def initialize(git_url)
    @repo_dir = Dir.mktmpdir
    @repo     = Git.clone(git_url, @repo_dir)
  end

  def read(file, args={})
    branch = args[:branch] || :master
    repo.cat_file "origin/#{branch}:#{file}"
  end

  def write(file, contents, args={})
    branch = args[:branch] || :master
    repo.checkout branch

    File.write File.join(repo_dir,file), contents
    repo.add file
    repo.commit 'one-shot-commit'

    repo.push 'origin', branch
  end

  def close
    FileUtils.rmtree repo_dir
  end

  private
  attr :repo, :repo_dir
  
end
