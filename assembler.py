class Assembler( object ):
    _BR_  = '001'
    _0BR_ = '010'
    _CAL_ = '011'
    _ADD_ = '000' + '00001' + '00000000'
    _SUB_ = '000' + '00010' + '00000000'
#    _OUT_ = '000' + '00011' + '00000000'
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
    _IOO_ = '000' + '10100' + '00000000'
    _IOI_ = '000' + '10101' + '00000000'
    _NOP_ = '0'*16

    _RET_MASK_ = 16-1 - 7

    def __init__( self ):
        self.code = []
        self.labels = {}
        self.labels_inv = {}
        self.instr = 0
        self.words = {}
        self.addr_width = 13

    def _addr2bin( self, addr ):
        return bin( addr )[ 2: ].zfill( self.addr_width )

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
        self.labels_inv[ self.instr ] = name

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

#    def out( self ):
#        self.code_append( Assembler._OUT_ )

    def branch( self, lbl ):
        self.code_append( Assembler._BR_ + lbl )
    
    def sla( self ):
        self.code_append( Assembler._SLA_ )

    def sra( self ):
        self.code_append( Assembler._SRA_ )

    def branch0( self, lbl ):
        self.code_append( Assembler._0BR_ + lbl )

    def dup( self ):
        self.code_append( Assembler._DUP_ )

    def not_( self ):
        self.code_append( Assembler._NOT_ )

    def call( self, lbl ):
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

    def drop( self ):
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

    def nop( self ):
        self.code_append( Assembler._NOP_ )

    def ret( self ):
        tmp = '0'*8 + '1'+ '0'*7
        self.code_append( tmp )

    def resw( self, name, addr, word ):
        self.words[ addr ] = ( name, word )

    def io_store( self, addr ): # I/O output
        self.lit( addr )
        self.code_append( Assembler._IOO_ )
        self.code_append( Assembler._DRP_ )

    def io_fetch( self, addr ): # I/O input
        self.lit( addr )
        self.code_append( Assembler._IOI_ )
    
    def full_code( self ):
        l = len( self.code )
        fcode = []

        jumpin_major_codes = [Assembler._CAL_, Assembler._0BR_, Assembler._BR_]

        # first pass through, match up labels with addresses and emit first pass of code
        for i, c in enumerate( self.code ):
            f = c[ :3 ]
            if self.labels_inv.has_key( i ) and f in jumpin_major_codes:
                label = self.labels_inv[ i ]
                self.labels[ label ] = i
                fcode.append( self.code[ i ] )
            else:
                fcode.append( self.code[ i ] )

        # patch up code with addresses, pad out to full length
        #   and insert data
        for i in xrange( 1, 2**self.addr_width ):
            if i < l and fcode[ i ][ :3 ] in jumpin_major_codes:
                label = self.labels[ fcode[ i ][ 3: ] ]
                label1 = bin( label )[ 2: ].rjust( 13, '0' )
                fcode[ i ] = fcode[ i ][ :3 ] + label1
                print fcode[ i ][ :3 ], label1, i, label
            elif self.words.has_key( i ):
                word = bin( self.words[ i ][ 1 ] )[ 2: ].rjust( 16, '0' )
                fcode.append( word )
            elif i >= l:
                fcode.append( Assembler._NOP_ )
        return fcode

    def write_code_file( self, filename, is_mif=False ):
        with open( filename, 'w' ) as f:
            if is_mif:
                print >>f, 'DEPTH = 8192;'
                print >>f, 'WIDTH = 16;'
                print >>f, 'ADDRESS_RADIX=DEC;'
                print >>f, 'DATA_RADIX=BIN;'
                print >>f, 'CONTENT'
                print >>f, 'BEGIN'
            for i, val in enumerate(self.full_code()):
                if is_mif:
                    print >>f, i, ' : ', val, ';'
                else:
                    print >>f, val
            if is_mif:
                print >>f, 'END;'

# GPIO I/O space addresses
_GPIO_OUT_ADDR = 0x10       # write
_GPIO_IN_ADDR = 0x10        # read
# UART I/O space addresses
_UART_START_ADDR = 0        # write
_UART_TX_DATA_ADDR = 1      # write
_UART_RX_BUSY_ADDR = 0      # read
_UART_TX_BUSY_ADDR = 1      # read
_UART_RX_DATA_ADDR = 2      # read

def uart_echo_test():
    a=Assembler()
    a.nop()

    # main loop
    a.call('rx_wait')

    # words

    # tx_byte           ( n -- )
    a.label('tx_byte')
    a.io_store(_UART_TX_DATA_ADDR)
    a.lit(1)
    a.io_store(_UART_START_ADDR)
    a.label('_1')
    a.io_fetch(_UART_TX_BUSY_ADDR)
    a.lit(0)
    a.equal()
    a.branch0('_1')
    a.ret()    

    # wait for RX Busy to go high
    a.label('rx_wait')
    a.io_fetch(_UART_RX_BUSY_ADDR)
    a.lit(1)
    a.equal()
    a.branch0('rx_wait')
    # wait for RX busy to go low
    a.label('_1')
    a.io_fetch(_UART_RX_BUSY_ADDR)
    a.lit(0)
    a.equal()
    a.branch0('_1')
    a.io_fetch(_UART_RX_DATA_ADDR)
    a.ret()
    
    return a

def blinky_test():
    a=Assembler()
    a.resw( 'count', 0x100, 0 )
    a.nop()

    a.label('loop')
    a.lit(32000)            # ( n )
    a.label('busy_wait')
    a.call('dec')
    a.dup()                 # ( n-1 n-1 )
    a.branch0('incr')       # ( n-1 )
    a.branch('busy_wait')

    ## words ##

    # increment ( n -- n+1 )
    a.label('inc')
    a.lit(1)
    a.add()
    a.ret()

    # decrement ( n -- n-1 )
    a.label('dec')
    a.lit(1)
    a.sub()
    a.ret()

    # wrap256   ( n -- n )
    a.label('wrap256')
    a.dup()         # ( n n )
    a.lit(256)      # ( n n 256 )
    a.equal()       # ( n t/f )
    a.branch0('_1') # ( n )
    a.drop()        # ()
    a.lit(0)        # ( 0 )
    a.label('_1')   # ( n )
    a.ret()

    ## end words ##

    # increment count and write its value to the GPIO pins
    a.label('incr')
    a.drop()                # ( -- )
    a.fetch('count')        # ( n )
    a.call('inc')           # ( n+1 )
    a.call('wrap256')       # ( n+1%256 )
    a.dup()                 # ( n n )
    a.store('count')        # ( n )
    
    # expects to get here with just n+1 on stack
    a.io_store(_GPIO_OUT_ADDR)
    a.branch('loop')

    return a

def uart_tx_test():
    a=Assembler()
    a.nop()
    a.branch('loop')

    ## words ##

    # dec               # ( n -- n-1 )
    a.label('dec')
    a.lit(1)
    a.sub()
    a.ret()

    # wait              # ( -- )
    a.label('wait')
    a.lit(500)          # ( n )
    a.label('waitloop')
    a.call('dec')       # ( n-1 )
    a.dup()             # ( n-1 n-1 )
    a.branch0('leave')  # ( n-1 )
    a.branch('waitloop')
    a.label('leave')
    a.drop()            # ( --)
    a.ret()

    # tx_byte           ( n -- )
    a.label('tx_byte')
    a.io_store(_UART_TX_DATA_ADDR)
    a.lit(1)
    a.io_store(_UART_START_ADDR)
    a.label('_1')
    a.io_fetch(_UART_TX_BUSY_ADDR)
    a.lit(0)
    a.equal()
    a.branch0('_1')
    a.ret()

    ## loops
    
    # main loop

    # TX a byte and wait for it to finish
    a.label('loop')
    a.call('wait')
    a.lit(65)
    a.call('tx_byte')
    a.branch('loop')

    return a
    

def gpio_test():
    a = Assembler()
    a.nop()

    # main loop
    a.label('loop')
    a.io_fetch(_GPIO_IN_ADDR)
    a.branch0('opposite')

    a.lit(0x55)
    a.io_store(_GPIO_OUT_ADDR)
    a.branch('loop')

    a.label('opposite')
    a.lit(0xAA)
    a.io_store(_GPIO_OUT_ADDR)
    a.branch('loop')

    return a    

def looper():
    a = Assembler()
    a.resw( 'count', 0x3ff, 10 )
    a.nop()

    # beginning of loop
    a.label( 'loop' )       
    a.fetch( 'count' )      # load count from memory   ( -- n )

    a.call( 'sub1&out' )    # call sub1&out ( n -- n-1 )

    a.dup()                 # ( -- n-1 n-1 )
    a.store( 'count' )      # ( -- n-1 )
    a.lit( 0 )              # ( -- n-1 0 )
    a.equal()               # ( -- t/f )
    a.branch0( 'loop' )
    #end of loop

    # done with loop, run word 'hang,' which sits in an infinite loop
    a.call( 'hang' )

    # word uart_tx, which outputs a byte to the UART and waits for it to finish TXing
    a.label( 'uart_tx' )    # ( n -- )
    a.io_store( _UART_TX_DATA_ADDR )
    a.lit( 1 )
    a.io_store( _UART_START_ADDR )
    # loop waiting for the TX to finish
    a.label( 'tx_wait_loop' )
    a.io_fetch( _UART_TX_BUSY_ADDR )
    a.lit(0)
    a.equal()
    a.branch0( 'tx_wait_loop' )
    a.ret()

    # word 'sub1&out', which subtracts 1 and outputs to I/O
    a.label( 'sub1&out' )   # ( n -- n-1 )
    a.lit( 1 )              # ( n 1 )
    a.sub()                 # ( n-1 )
    a.dup()                 # ( n-1 n-1 )
    a.call( 'uart_tx' )     # ( n-1 n-1 -- n-1 )
    a.ret()                 # return from subroutine

    # word 'hang' which is an infinite loop of nothing
    a.label( 'hang' )       # ( -- )
    a.branch( 'hang' )
            
    return a
