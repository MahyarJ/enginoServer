require! {
  'when': wn
  '../../lib'
}

module.exports = (params) ->
  wn.promise (resolve, reject) ->
    # console.log engino
    # console.log lib 
    resolve params.name + ' :)'
