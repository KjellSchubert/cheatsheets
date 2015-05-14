Some boost-asio notes:
* async_write needs to ensure the buffer it gets as an arg stays alive until
the callback is called (since its a zero-copy impl?).
* casablanca aka cpprest is a neat lib for cross-platform C++ json rest APIs,
  I only had some problems with disabling nagle & fine control of chunked 
  transfer encoding timing.

```
// may be useful some time for heartbeats (I had used it for initial testing)
// repeat calling action() $count times every $ms via asio event loop.
void repeat(boost::asio::io_service& io_service,
            std::chrono::milliseconds ms,
            int count,
            const std::function<void()>& action) {

  // about steady_timer: it will insta-fire once it's d'tor runs, so we must
  // defer destruction until timer expired & got handled. With C++14 lambda
  // bind exprs we can make this a unique_ptr btw, shared_ptr until then.
  auto timer = std::make_shared<boost::asio::steady_timer>(io_service, ms);
  timer->async_wait([&io_service, ms, count, action, timer](
      const boost::system::error_code& err) {
    if (!err) {
      action();
      if (count > 1)
        repeat(io_service, ms, count - 1, action);
    } else {
      // timer got cancelled, stop the whole repeat-chain
      std::cout << "repeat() timer cancelled\n";
      return;
    }
  });
}
```

