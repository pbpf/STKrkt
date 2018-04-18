#Python Script for sending TCP/IP Connect Commands to STK
import time as tm
import socket as so
import threading as th
from collections import deque


class SafeList( deque ):
    def __init__( self ):
        deque.__init__( self )
        self.mtx = th.Semaphore()
        self.cItem = 0
        self.ilast = 0
        self.hitLimit = False
        
    def __getitem__( self, key ):
        if self.mtx.acquire():
            values = deque.__getitem__( self, key )
            self.mtx.release()
        return values

    def __setitem__( self, key, value ):
        if self.mtx.acquire():
            values = deque.__setitem__( self, key, value )
            self.mtx.release()

    def get( self ):
        if self.mtx.acquire():
            if deque.__len__( self ) <= self.cItem:
                item = None
            else:
                item = deque.__getitem__( self, self.cItem )
            self.mtx.release()
        return item

    def lItem( self ):
        if self.mtx.acquire():
            if self.ilast == 0:
                item = None
            else:
                item = deque.__getitem__( self, self.ilast-1 )
            self.mtx.release()
        return item
    
    def push( self, value ):
        if self.mtx.acquire():
            values = deque.append( self, value )
            self.ilast = self.ilast + 1
            if self.hitLimit:
                self.hitLimit = False
                self.cItem = self.cItem + 1
            self.mtx.release()

    def pop( self ):
        if self.mtx.acquire():
            values = deque.popleft( self )
            self.cItem = self.cItem - 1
            self.ilast = self.ilast - 1
            self.mtx.release()
        return values

    def next( self ):
        if self.mtx.acquire():
            if deque.__len__( self ) <= self.cItem:
                self.hitLimit = True
                
            if not self.hitLimit:
                self.cItem = self.cItem + 1
            self.mtx.release()
        return self.cItem 

# Encapsulate the commands requested to be sent.
# Will probably be cleared at some point so store needed
# data at some other point.
class ConnCmd():
    def __init__( self, command, state = None, multi = False, mWait = 1 ):
        self.command = command
        self.state = state
        self.extra = []
        self.multi = multi
        self.mWait = mWait
        

# Encapsulates a Socket... Works off commands which need
# an acknowledge or data returned.
class Connection( th.Thread ):
    def __init__( self, ip, port ):
        th.Thread.__init__( self )
        # Constant Variables
        self.maxCmdStore = 100
        self.recvMaxByte = 2048
        # Variables to track interface commands
        self.commands = SafeList()
        # Socket Variables
        self.connected = False
        self.address = ( ip, port )
        self.socket = so.socket( so.AF_INET, so.SOCK_STREAM )

    def Reconnect( self ):
        try:
            self.socket.connect( self.address )
            self.connected = True
            print( 'Connected' )
        except so.error as msg:
            print( msg )
            self.connected = False        
        
    def Connect( self ):
        print( 'Connecting' )
        self.StayConnected = True
        self.start()     

    def WaitComplete( self ):
        while self.commands.lItem().state == None:
            print( 'waiting' )
            tm.sleep( 0.5 ) # just to break the scheduling
            if not self.connected:
                break
        
    def Disconnect( self, force ):
        if not force:
            self.WaitComplete()
        print( 'Disconnecting' )
        self.StayConnected = False

    def sendCommand( self, data ):
        if not data.command[-1] == '\n': # add a \n cause i keep forgetting.
            data.command = data.command + '\n'
        self.commands.push( data )
        if len( self.commands ) > self.maxCmdStore:
            self.commands.pop()

    def SendData( self ):
        try:
            self.socket.sendall( self.commands.get().command.encode() )
        except so.error as msg:
            print( msg )
            self.connected = False

    def GetData( self ):
        cComm = self.commands.get()
        getPackets = True
        
        while getPackets:
            try:
                if cComm.multi:
                    self.socket.settimeout( cComm.mWait ) 
                data = self.socket.recv( self.recvMaxByte )
                self.socket.settimeout( None ) 
            except so.error as msg:
                print( msg )
                if not 'timed out' in str(msg):
                    self.connected = False
                    return
                    
                elif cComm.multi:
                    cComm.state = True
        
            if len( data ) == 0:
                self.connected = False
                return

            msg = data.decode()
            cComm.extra.append( msg )

            if not cComm.multi:
                cComm.state = (True, False)[msg == 'ACK']
            getPackets = cComm.multi or cComm.state
            
        self.commands.next()
        
            
    def run( self ):
        print( 'Running' )
        while self.StayConnected:
            if not self.connected:
                self.Reconnect()
            else:
                if len(self.commands) > 0:
                    cmd = self.commands.get()
                    if cmd and cmd.state == None:
                        self.SendData()
                        self.GetData()            

        if self.connected:
            self.socket.shutdown( so.SHUT_RDWR )
            self.socket.close()
        print( 'Stopped' )