class Assembler( object ):
    _BR_  = '001'
    _0BR_ = '010'
    _1BR_ = '011'
    _ADD_ = '000' + '00001' + '00000000'
    _SUB_ = '000' + '00010' + '00000000'
    _OUT_ = '000' + '00011' + '00000000'
    _SLA_ = '000' + '00100' + '00000000'
    _SRA_ = '000' + '00101' + '00000000'
    _DUP_ = '000' + '00110' + '00000000'
    _NOT_ = '000' + '00111' + '00000000'
    _FTC_  = '000' + '01000' + '00000000'
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
    _NOP_ = '0'*16

    def __init__( self ):
        self.code = []
        self.labels = {}
        self.instr = 0
        self.words = {}
        self.addr_width = 13

    def _addr2bin( self, addr ):
        return bin(addr)[2:].zfill( self.addr_width )

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
        baddr = self._addr2bin( lbladdr )
        self.code_append( Assembler._BR_ + baddr )
    
    def sla( self ):
        self.code_append( Assembler._SLA_ )

    def sra( self ):
        self.code_append( Assembler._SRA_ )

    def branch0( self, lbl ):
        lbladdr = self.labels[ lbl ]
        baddr = self._addr2bin( lbladdr )
        self.code_append( Assembler._0BR_ + baddr )

    def dup( self ):
        self.code_append( Assembler._DUP_ )

    def not_( self ):
        self.code_append( Assembler._NOT_ )

    def branch1( self, lbl ):
        lbladdr = self.labels[ lbl ]
        baddr = self._addr2bin( lbladdr )
        self.code_append( Assembler._1BR_ + baddr )

    def fetch( self, addr ):
        self.lit( addr )
        self.code_append( Assembler._FTC_ )

    def store( self, addr ):
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

    def resw( self, addr, word ):
        self.words[ addr ] = word
    
    def full_code( self ):
        l = len(self.code)
        fcode = self.code[::]
        for i in xrange( l, 2**self.addr_width ):
            if self.words.has_key( i ):
                word = bin(self.words[ i ])[2:].rjust( 16, '0' )
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
    a.resw( 0x3ff, 10 )
    a.label( 'loop' )
    a.fetch( 0x3ff )
    a.lit( 1 )
    a.sub()
    a.out()
    a.dup()
    a.store( 0x3ff )
    a.branch1( 'loop' )
    return a
