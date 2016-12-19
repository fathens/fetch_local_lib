
module FetchLocalLib
    class Credential
        def self.bitbucket
            build(ENV['BITBUCKET_USERNAME'], ENV['BITBUCKET_PASSWORD'])
        end

        def self.build(username, password)
            if username && password
                obj = Credential.new
                obj.username = username
                obj.password = password
                obj
            else
                nil
            end
        end

        attr_accessor :username, :password

        def to_s
            [@username, @password].compact.map {|s| s.shellescape }.join(':')
        end

        def inject_to(url)
            url.sub(/^https:\/\//, "https://#{to_s}@")
        end
    end
end
