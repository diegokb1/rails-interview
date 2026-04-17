module ApiClient
  class Items < Base
    def self.create(list_id, params)
      post("/todo_lists/#{list_id}/todo_items", body: params.to_json, headers: headers)
    end

    def self.update(list_id, id, params)
      put("/todo_lists/#{list_id}/todo_items/#{id}", body: params.to_json, headers: headers)
    end

    def self.destroy(list_id, id)
      delete("/todo_lists/#{list_id}/todo_items/#{id}", headers: headers)
    end
  end
end
