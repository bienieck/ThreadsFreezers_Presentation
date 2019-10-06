<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="15008000">
	<Item Name="My Computer" Type="My Computer">
		<Property Name="NI.SortType" Type="Int">3</Property>
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">My Computer/VI Server</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="Source" Type="Folder">
			<Item Name="Globals" Type="Folder">
				<Item Name="Stop.vi" Type="VI" URL="../Source/Stop.vi"/>
				<Item Name="Wait.vi" Type="VI" URL="../Source/Wait.vi"/>
			</Item>
			<Item Name="Misc" Type="Folder">
				<Item Name="Milliseconds To Wait From Global.vi" Type="VI" URL="../Source/Milliseconds To Wait From Global.vi"/>
				<Item Name="Process.vi" Type="VI" URL="../Source/Process.vi"/>
				<Item Name="Toggle LED.vi" Type="VI" URL="../Source/Toggle LED.vi"/>
			</Item>
		</Item>
		<Item Name="Gates.lvlib" Type="Library" URL="../../Gates/Gates.lvlib"/>
		<Item Name="Example.vi" Type="VI" URL="../Source/Example.vi"/>
		<Item Name="Dependencies" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="Error Cluster From Error Code.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Error Cluster From Error Code.vi"/>
			</Item>
		</Item>
		<Item Name="Build Specifications" Type="Build"/>
	</Item>
</Project>
