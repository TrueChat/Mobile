class Response{
  bool _isError;
  String _message;

  bool get isError => _isError;
  String get message => _message;

  Response(this._isError,this._message);
}