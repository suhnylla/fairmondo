/*
 * Farinopoly - Fairnopoly is an open-source online marketplace.
 * Copyright (C) 2013 Fairnopoly eG
 *
 * This file is part of Farinopoly.
 *
 * Farinopoly is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * Farinopoly is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with Farinopoly.  If not, see <http://www.gnu.org/licenses/>.

*/


$(document).ready(function(){

	$('#login-link').on('click', function (e) {
		$.colorbox({
			transition: "none",
			width: "75%",
			opacity: 0.4,
			height: "75%",
			href:$(this).attr('href')});
			return false;
	} );

});