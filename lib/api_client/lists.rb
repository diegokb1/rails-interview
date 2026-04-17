module ApiClient
  class Lists < Base
    def self.create(params)
      post('/todo_lists', body: params.to_json, headers: headers)
    end

    def self.update(id, params)
      put("/todo_lists/#{id}", body: params.to_json, headers: headers)
    end

    def self.destroy(id)
      delete("/todo_lists/#{id}", headers: headers)
    end

    def self.get_all
      get("/todo_lists")
    end
  end
end
