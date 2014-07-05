class Assembler( object ):
    _BR_  = '001'
    _0BR_ = '010'
    _CAL_ = '011'
    _ADD_ = '000' + '00001' + '00000000'
    _SUB_ = '000' + '00010' + '00000000'
    _OUT_ = '000' + '00011' + '00000000'
    _SLA_ = '000' + '00100' + '00000000'
    _SRA_ = '000' + '00101' + '00000000'
    _DUP_ = '000' + '00110' + '00000000'
    _NOT_ = '000' + '00111' + '00000000'
    _FTC_ = '000' + '01000' + '00000000'
    _STR_ = '000' + '01001' + '00000000'
    _DTR_ = '000' + '01010' + '00000000'
    _DRP_ = '000' + '01011' + '00000000'
    _RTD_ = '000' + '01100' + '00000000'
    _ROT_ = '000' + '01101' + '00000000'
    _NRT_ = '000' + '01110' + '00000000'
    _SWP_ = '000' + '01111' + '00000000'
    _NIP_ = '000' + '10000' + '00000000'
    _TCK_ = '000' + '10001' + '00000000'
    _OVR_ = '000' + '10010' + '00000000'
    _EQU_ = '000' + '10011' + '00000000'
    _NOP_ = '0'*16

    _RET_MASK_ = 0x1 << 7

    def __init__( self ):
        self.code = []
        self.labels = {}
        self.labels_inv = {}
        self.instr = 0
        self.words = {}
        self.addr_width = 13

    def _addr2bin( self, addr ):
        return bin(addr)[2:].zfill( self.addr_width )

    def _findname( self, name ):
        for addr in self.words:
            if self.words[ addr ][ 0 ] == name:
                return addr
        assert 0, ('Name not found %s' % name)
        
    def code_append( self, c ):
        self.code.append( c )
        self.instr = self.instr + 1

    def label( self, name ):
        self.labels[ name ] = self.instr
        self.labels_inv[ self.isntr ] = name

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
        #lbladdr = self.labels[ lbl ]
        #baddr = self._addr2bin( lbladdr )
        #self.code_append( Assembler._BR_ + baddr )
        self.code_append( Assembler._BR_ + lbl )
    
    def sla( self ):
        self.code_append( Assembler._SLA_ )

    def sra( self ):
        self.code_append( Assembler._SRA_ )

    def branch0( self, lbl ):
##        lbladdr = self.labels[ lbl ]
##        baddr = self._addr2bin( lbladdr )
##        self.code_append( Assembler._0BR_ + baddr )
        self.code_append( Assembler._0BR_ + lbl )

    def dup( self ):
        self.code_append( Assembler._DUP_ )

    def not_( self ):
        self.code_append( Assembler._NOT_ )

    def call( self, lbl ):
##        lbladdr = self.labels[ lbl ]
##        baddr = self._addr2bin( lbladdr )
##        self.code_append( Assembler._1BR_ + baddr )
        self.code_append( Assembler._CAL_ + lbl )

    def fetch( self, name ):
        addr = self._findname( name )
        self.lit( addr )
        self.code_append( Assembler._FTC_ )

    def store( self, name ):
        addr = self._findname( name )
        self.lit( addr )
        self.code_append( Assembler._STR_ )
        self.code_append( Assembler._DRP_ )

    def drop( self, addr ):
        self.code_append( Assembler._DRP_ )

    def rtd( self ):
        self.code_append( Assembler._RTD_ )

    def dtr( self ):
        self.code_append( Assembler._DTR_ )

    def rot( self ):
        self.code_append( Assembler._ROT_ )

    def nrot( self ):
        self.code_append( Assembler._NRT_ )

    def swap( self ):
        self.code_append( Assembler._SWP_ )

    def nip( self ):
        self.code_append( Assembler._NIP_ )

    def tuck( self ):
        self.code_append( Assembler._TCK_ )

    def over( self ):
        self.code_append( Assembler._OVR_ )

    def equal( self ):
        self.code_append( Assembler._EQU_ )

    def ret( self ):
        self.code_append( Assembler._NOP_ | Assembler._RET_MASK_ )

    def resw( self, name, addr, word ):
        self.words[ addr ] = ( name, word )
    
    def full_code( self ):
        l = len(self.code)
        fcode = self.code[::]
        for i in xrange( l, 2**self.addr_width ):
            if self.labels
            if self.words.has_key( i ):
                word = bin(self.words[ i ][ 1 ])[2:].rjust( 16, '0' )
                fcode.append( word )
            else:
                fcode.append( Assembler._NOP_ )
        return fcode

    def write_code_file( self, filename ):
        with open( filename, 'w' ) as f:
            for i in self.full_code():
                print >>f, i
    
def looper():
    a = Assembler()
    a.resw( 'count', 0x3ff, 10 )
    a.label( 'loop' )
    a.fetch( 'count' )
    a.lit( 1 )
    a.sub()
    a.out()
    a.dup()
    a.store( 'count' )
    a.lit( 0 )
    a.equal()
    a.branch0( 'loop' )
    return a
