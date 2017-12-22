var should     = require( 'should' );
var Collection = require( '../dist/lib/collection' );

// dummie data
users = [
  {
    name : 'lorem',
    pass : 'ipsum'
  },
  {
    name : 'dolor',
    pass : 'amet'
  }
];

describe( 'Collection class', function() {
  describe( 'construct collection instances', function() {
    it( 'constructor without arguments should be an error', function() {
      should( function() { return new Collection() } ).throw( 'type needs to be specified on first argument of constructor' );
    } );

    it( 'create collection of objects', function() {
      ( new Collection( Object ) ).should.be.an.instanceOf( Collection );
    } );

    it( 'create collection with init items that isnt instance of array (error)', function() {
      should( function() { return new Collection( Object, 'lorem' ) } ).throw( 'collection must be an array' );
    } );

    it( 'create collection with init items', function() {
      ( new Collection( Object, users ) ).should.be.and.instanceOf( Collection );
    } );
  } );

  describe( 'collection methods', function() {
    it( 'get() should be equals to init data', function() {
      ( new Collection( Object, users ) ).get().should.be.equals( users );
    } );

    it( 'findByKey( \'name\' ) needs to be an array with two elements', function() {
      ( new Collection( Object, users ) ).findByKey( 'name' ).length.should.be.equal( 2 );
    } )

    it( 'findByKey( \'name\', \'lorem\' ) needs to be an array with one element', function() {
      ( new Collection( Object, users ) ).findByKey( 'name', 'lorem' ).length.should.be.equal( 1 );
    } );

    it( 'register() throw an error if not instance of @_type (object)', function() {
      var userCollection = new Collection( Object, users );
      ( function() { userCollection.register( 'lorem' ) } ).should.throw();
    } );

    it( 'register() success', function() {
      var userCollection = new Collection( Object, users );
      userCollection.register( { name : 'rabrux', pass : 'access' } ).should.be.a.number;
    } );

    it( 'remove() one element', function() {
      var userCollection = new Collection( Object, users );
      toRemove = userCollection.findByKey( 'name', 'lorem' );
      userCollection.remove( toRemove ).get().length.should.be.equal( 1 );
    } );

  } );

} );

