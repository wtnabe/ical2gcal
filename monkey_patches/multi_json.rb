module MultiJson
  alias_method :orig_load, :load

  #
  # google-api-client の credentials の読み取りの部分で ActiveSupport
  # の String でも Symbol でもいい具合に扱っている機能に依存していたが
  # MultiJson が ActiveSupport を drop して動かなくなった問題へのパッチ
  #
  # 他の項目は Symbol と String の両方で読み取りを試みるが :flow だけ
  # Symbol しか試みていないので詰め直している
  #
  # @param [String] json_string
  # @return [Object]
  #
  def self.load(json_string)
    json = orig_load(json_string)

    if json && json.has_key?("flow")
      json[:flow] = json["flow"]
    end

    json
  end
end
