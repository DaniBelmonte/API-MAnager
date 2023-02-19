# API-Manager

<pre><code>func callAPI&lt;T: Decodable&gt;(endpoint: String, method: HTTPMethod, params: [String: Any]?) async throws -&gt; T {}
</code></pre>
<p>This is a function that uses Swift <code>async/await</code> syntax to make an API call to a specified endpoint. It takes in three parameters: the endpoint string, the HTTP method to use (GET, POST, PUT, DELETE), and an optional dictionary of parameters to include in the API call. It also uses a generic type T that conforms to the <code>Decodable</code> protocol, which means the function can return any type that can be decoded from JSON.</p>
<pre><code>let urlString = "\(baseUrl)\(endpoint)"
var urlComponents = URLComponents(string: urlString)
var queryItems = [URLQueryItem]()
if let params = params {
    for (key, value) in params {
        queryItems.append(URLQueryItem(name: key, value: "\(value)"))
    }
    urlComponents?.queryItems = queryItems
}
</code></pre>
<p>These lines of code construct the URL that will be used in the API call. It first combines the base URL with the specified endpoint to get the full URL string. It then creates a <code>URLComponents</code> object from the URL string, which allows you to easily add query parameters. If there are any parameters passed into the function, it loops through them and adds them as query items to the URL.</p>
<pre><code>guard let url = urlComponents?.url else {
    throw URLError(.badURL)
}
var request = URLRequest(url: url)
request.httpMethod = method.rawValue
</code></pre>
<p>This section of code uses the <code>URLComponents</code> object created earlier to get the final URL for the API call. It then creates a <code>URLRequest</code> object with that URL and the specified HTTP method.</p>
<pre><code>let (data, response) = try await URLSession.shared.data(for: request)
guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode) else {
    throw APIError.invalidResponse
}
</code></pre>
<p>These lines of code use Swift <code>async/await</code> syntax to make the API call using <code>URLSession</code>. Checks if the response from the API is valid (status code 200-299) and throws an error if it is not.</p>
<pre><code>do {
    let decoder = JSONDecoder()
    let object = try decoder.decode(T.self, from: data)
    return object
} catch {
    throw error
}
</code></pre>
<p>Finally, this section of code uses <code>JSONDecoder</code> to decode the JSON response from the API into the specified type T. If it succeeds, it returns the decoded object. If it fails, it throws an error.</p>
