require 'uri'
require 'pathname'
require 'fileutils'
require 'shellwords'
require 'git'
require 'fetch_local_lib/credential'

module FetchLocalLib
    class Repo
        def self.github(base_dir, repo_path, tag: nil)
            Repo.new("https://github.com/#{repo_path}.git", base_dir, tag: tag)
        end

        def self.bitbucket(base_dir, repo_name, owner: 'fathens', tag: nil)
            Repo.new("https://bitbucket.org/#{owner}/#{repo_name}.git", base_dir,
                tag: tag,
                cred: Credential.bitbucket
            )
        end

        attr_accessor :url, :name, :base_dir, :hidden_path, :tag, :cred

        def initialize(url, base_dir = nil, tag: nil, cred: nil, username: nil, password: nil)
            @url = url
            @name = File.basename(URI.parse(url).path, '.git')
            @base_dir = base_dir || Pathname.pwd
            @hidden_path = '.repo'
            @tag = tag || "master"
            @cred = cred || Credential.build(username, password)
        end

        def dir
            base_dir/hidden_path/name
        end

        def cloned
            @cloned ||= begin
                g = Git.open(dir)
                g.remotes.map(&:url).find(url) ? g : nil
            rescue => ex
                nil
            end
        end

        def git_clone
            if dir.exist?
                if cloned
                    cloned.checkout(tag)
                    return dir
                end
                FileUtils.rm_rf(dir)
            end
            target_url = @cred&.inject_to(@url) || @url
            Git.clone(target_url, name, path: dir.dirname.to_s).checkout(tag)
            return dir
        end
    end
end
