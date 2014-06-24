class Assembler( object ):
    _ADD_ = '0000010000000000'
    _SUB_ = '0000100000000000'
    _OUT_ = '0000110000000000'
    _BR_  = '000100'
    _ALS_ = '0001010000000000'
    _ARS_ = '0001100000000000'
    _0BR_ = '000111'
    _DUP_ = '0010000000000000'
    _NOT_ = '0010010000000000'
    _1BR_ = '001010'
    _LD_  = '001011'
    _PUT_ = '001100'
    _DTR_ = '0011010000000000'
    _DRP_ = '0011100000000000'
    _RTD_ = '0011110000000000'
    _NOP_ = '0'*16

    def __init__( self ):
        self.code = []
        self.labels = {}
        self.instr = 0
        self.words = {}

    def _addr2bin( self, addr ):
        return bin(addr)[2:].zfill(10)

    def code_append( self, c ):
        self.code.append( c )
        self.instr = self.instr + 1

    def label( self, name ):
        self.labels[ name ] = self.instr

    def lit( self, l ):
        assert l <= (2**15) and l >= -(2**15)+1
        tmp = bin(l)[2:]
        if l >= 0:
            tmp = '1' + tmp.rjust(15, '0')
        else:
            tmp = '1' + tmp.rjust(15, '1')
        self.code_append( tmp )

    def add( self ):
        self.code_append( Assembler._ADD_ )

    def sub( self ):
        self.code_append( Assembler._SUB_ )

    def out( self ):
        self.code_append( Assembler._OUT_ )

    def branch( self, lbl ):
        lbladdr = self.labels[ lbl ]
        baddr = self._addr2bin(lbladdr)
        self.code_append( Assembler._BR_ + baddr )
    
    def als( self ):
        self.code_append( Assembler._ALS_ )

    def ars( self ):
        self.code_append( Assembler._ARS_ )

    def branch0( self, lbl ):
        lbladdr = self.labels[ lbl ]
        baddr = self._addr2bin(lbladdr)
        self.code_append( Assembler._0BR_ + baddr )

    def dup( self ):
        self.code_append( Assembler._DUP_ )

    def not_( self ):
        self.code_append( Assembler._NOT_ )

    def branch1( self, lbl ):
        lbladdr = self.labels[ lbl ]
        baddr = self._addr2bin(lbladdr)
        self.code_append( Assembler._1BR_ + baddr )

    def load( self, addr ):
        baddr = self._addr2bin( addr )
        self.code_append( Assembler._LD_  + baddr)

    def put( self, addr ):
        baddr = self._addr2bin( addr )
        self.code_append( Assembler._PUT_ + baddr )

    def drop( self, addr ):
        self.code_append( Assembler._DRP_ )

    def rtd( self ):
        self.code_append( Assembler._RTD_ )

    def dtr( self ):
        self.code_append( Assembler._DTR_ )

    def resw( self, addr, word ):
        self.words[ addr ] = word
    
    def full_code( self ):
        l = len(self.code)
        fcode = self.code[::]
        for i in xrange( l, 1024 ):
            if self.words.has_key( i ):
                word = bin(self.words[ i ])[2:].rjust( 16, '0' )
                fcode.append( word )
            else:
                fcode.append( Assembler._NOP_ )
        return fcode
    
def looper():
    a = Assembler()
    a.resw( 0x3ff, 10 )
    a.label('loop')
    a.load(0x3ff)
    a.lit(1)
    a.sub()
    a.out()
    a.dup()
    a.dup()
    a.dtr()
    a.put(0x3ff)
    a.branch1('loop')
    a.rtd()
    return a
    
